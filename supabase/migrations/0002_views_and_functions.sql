-- =====================================================================
-- VIS — Views e Funções SQL (09_SUPABASE_SQL.md)
--
-- Implementa as views e funções previstas na especificação. Hoje esses
-- cálculos são feitos no cliente (offline-first); estas definições movem
-- a fonte de verdade para o servidor (Dashboard < 300ms, escalabilidade).
--
-- Todas as views usam `security_invoker = true` para que a RLS das
-- tabelas-base continue valendo (o usuário só vê os próprios dados).
--
-- IMPORTANTE: valide os nomes de colunas contra o schema aplicado antes
-- de rodar em produção (segue os nomes de 03_DATABASE.md).
-- =====================================================================

-- ---------------------------------------------------------------------
-- Funções puras
-- ---------------------------------------------------------------------

-- 1RM estimado (fórmula de Epley). Determinística.
create or replace function public.calculate_estimated_1rm(
  weight numeric, reps integer
) returns numeric
language sql immutable
as $$
  select case
    when weight is null or reps is null or reps <= 0 then null
    else round(weight * (1 + reps / 30.0), 2)
  end;
$$;

-- Volume total de uma sessão (soma peso × reps das séries concluídas,
-- excluindo aquecimento).
create or replace function public.calculate_training_volume(session_id uuid)
returns numeric
language sql stable
as $$
  select coalesce(sum(es.weight * es.repetitions), 0)
  from public.exercise_sets es
  where es.workout_session_id = session_id
    and es.completed
    and coalesce(es.set_type, '') <> 'warmup';
$$;

-- Dias consecutivos de treino terminando hoje ou ontem (gaps & islands).
create or replace function public.streak_days(uid uuid)
returns integer
language sql stable
as $$
  with days as (
    select distinct date(coalesce(finished_at, started_at)) as d
    from public.workout_sessions
    where user_id = uid and deleted_at is null
  ),
  ranked as (
    select d,
           (d - (row_number() over (order by d))::int) as grp
    from days
  ),
  last_island as (
    select count(*) as cnt, max(d) as max_d
    from ranked
    where grp = (select grp from ranked order by d desc limit 1)
  )
  select case
    when (select max_d from last_island) >= current_date - 1
      then coalesce((select cnt from last_island), 0)
    else 0
  end::int;
$$;

-- Séries por músculo na semana atual.
create or replace function public.weekly_sets(uid uuid)
returns table(muscle text, sets bigint)
language sql stable
as $$
  select e.primary_muscle as muscle, count(*) as sets
  from public.exercise_sets es
  join public.workout_sessions s on s.id = es.workout_session_id
  join public.exercise_library e on e.id = es.exercise_id
  where s.user_id = uid
    and es.completed
    and s.started_at >= date_trunc('week', now())
  group by e.primary_muscle
  order by sets desc;
$$;

-- Resumo mensal (últimos 12 meses): treinos e volume por mês.
create or replace function public.monthly_progress(uid uuid)
returns table(month date, workouts bigint, volume numeric)
language sql stable
as $$
  select date_trunc('month', s.started_at)::date as month,
         count(distinct s.id) as workouts,
         coalesce(sum(es.weight * es.repetitions) filter (where es.completed), 0) as volume
  from public.workout_sessions s
  left join public.exercise_sets es on es.workout_session_id = s.id
  where s.user_id = uid
    and s.started_at >= date_trunc('month', now()) - interval '11 months'
  group by 1
  order by 1;
$$;

-- Contexto para a IA: JSON com perfil + históricos recentes.
-- Espelha o AIContext montado hoje no cliente (ai_context_builder.dart).
create or replace function public.ai_context(uid uuid)
returns jsonb
language sql stable
as $$
  select jsonb_build_object(
    'profile', (
      select to_jsonb(u) - 'created_at' - 'updated_at'
      from public.users u where u.id = uid
    ),
    'memory', (
      select to_jsonb(m) from public.ai_memory m where m.user_id = uid limit 1
    ),
    'recent_sessions', (
      select coalesce(jsonb_agg(x), '[]'::jsonb) from (
        select s.day_name, s.started_at, s.total_volume, s.total_sets
        from public.workout_sessions s
        where s.user_id = uid and s.deleted_at is null
        order by s.started_at desc limit 10
      ) x
    ),
    'weight_history', (
      select coalesce(jsonb_agg(x), '[]'::jsonb) from (
        select weight, created_at from public.weight_history
        where user_id = uid order by created_at desc limit 20
      ) x
    ),
    'cardio', (
      select coalesce(jsonb_agg(x), '[]'::jsonb) from (
        select type, distance, duration, performed_at
        from public.cardio_sessions
        where user_id = uid order by performed_at desc limit 10
      ) x
    ),
    'prs', (
      select coalesce(jsonb_agg(x), '[]'::jsonb) from (
        select exercise_id, weight, repetitions, estimated_1rm
        from public.personal_records where user_id = uid
      ) x
    ),
    'streak_days', public.streak_days(uid)
  );
$$;

-- ---------------------------------------------------------------------
-- Views (RLS herdada via security_invoker)
-- ---------------------------------------------------------------------

-- Recordes por usuário + exercício.
create or replace view public.exercise_prs
with (security_invoker = true) as
  select s.user_id,
         es.exercise_id,
         max(es.weight) as max_weight,
         max(es.weight * es.repetitions) as max_volume,
         max(public.calculate_estimated_1rm(es.weight, es.repetitions)) as max_estimated_1rm
  from public.exercise_sets es
  join public.workout_sessions s on s.id = es.workout_session_id
  where es.completed
    and coalesce(es.set_type, '') <> 'warmup'
    and es.weight is not null
  group by s.user_id, es.exercise_id;

-- Volume semanal por grupo muscular.
create or replace view public.weekly_volume
with (security_invoker = true) as
  select s.user_id,
         e.primary_muscle,
         sum(es.weight * es.repetitions) as volume
  from public.exercise_sets es
  join public.workout_sessions s on s.id = es.workout_session_id
  join public.exercise_library e on e.id = es.exercise_id
  where es.completed
    and s.started_at >= date_trunc('week', now())
  group by s.user_id, e.primary_muscle;

-- Balanço de volume por músculo (todo o histórico).
create or replace view public.muscle_balance
with (security_invoker = true) as
  select s.user_id,
         e.primary_muscle,
         sum(es.weight * es.repetitions) as volume
  from public.exercise_sets es
  join public.workout_sessions s on s.id = es.workout_session_id
  join public.exercise_library e on e.id = es.exercise_id
  where es.completed
  group by s.user_id, e.primary_muscle;

-- Linha do tempo de evolução corporal (peso + medidas + fotos).
create or replace view public.body_progress
with (security_invoker = true) as
  select user_id, 'weight'::text as kind, created_at as at,
         weight::text as value
  from public.weight_history where deleted_at is null
  union all
  select user_id, 'measurement'::text, created_at, null::text
  from public.body_measurements where deleted_at is null
  union all
  select user_id, 'photo'::text, created_at, photo_type::text
  from public.progress_photos where deleted_at is null;

-- Resumo do Dashboard (uma linha por usuário).
create or replace view public.dashboard_summary
with (security_invoker = true) as
  select u.id as user_id,
    (select count(*) from public.workout_sessions s
       where s.user_id = u.id and s.finished_at is not null
       and s.deleted_at is null) as total_workouts,
    (select weight from public.weight_history w
       where w.user_id = u.id order by created_at desc limit 1) as current_weight,
    (select max(finished_at) from public.workout_sessions s
       where s.user_id = u.id) as last_workout,
    (select max(performed_at) from public.cardio_sessions c
       where c.user_id = u.id) as last_cardio,
    (select max(created_at) from public.progress_photos p
       where p.user_id = u.id) as last_photo,
    (select max(created_at) from public.body_measurements m
       where m.user_id = u.id) as last_measurement,
    public.streak_days(u.id) as streak_days
  from public.users u;

-- =====================================================================
-- Fim. As Edge Functions de IA (ai-answer, ai-create-workout,
-- ai-analyze-photos) podem consumir public.ai_context(uid) para montar o
-- contexto do usuário no servidor.
-- =====================================================================
