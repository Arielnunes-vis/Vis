-- =====================================================================
-- VIS — Baseline de segurança e performance (Supabase / PostgreSQL)
-- Referências: 03_DATABASE.md, 09_SUPABASE_SQL.md
--
-- Este arquivo implementa o que a especificação exige e que ainda não
-- existia no projeto: RLS em todas as tabelas de usuário, políticas por
-- auth.uid(), índices das consultas frequentes, trigger de updated_at e
-- políticas de Storage (buckets privados + URLs assinadas).
--
-- IMPORTANTE: reconcilie os nomes de colunas com o schema efetivamente
-- aplicado antes de rodar em produção. Idempotente onde possível
-- (IF NOT EXISTS / CREATE OR REPLACE / DROP POLICY IF EXISTS).
-- Nunca há DELETE físico — apenas soft delete (deleted_at).
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Trigger utilitário: mantém updated_at sempre atualizado
-- ---------------------------------------------------------------------
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- Aplica o trigger a todas as tabelas que possuem updated_at.
do $$
declare
  t text;
begin
  foreach t in array array[
    'users','workout_plans','ai_memory'
  ]
  loop
    execute format(
      'drop trigger if exists trg_set_updated_at on public.%I;', t);
    execute format(
      'create trigger trg_set_updated_at before update on public.%I '
      'for each row execute function public.set_updated_at();', t);
  end loop;
end $$;

-- ---------------------------------------------------------------------
-- 2. Índices das consultas frequentes (09_SUPABASE_SQL — Índices)
--    Composto (user_id, created_at desc) habilita paginação eficiente.
-- ---------------------------------------------------------------------
create index if not exists idx_workout_plans_user       on public.workout_plans (user_id) where deleted_at is null;
create index if not exists idx_workout_plans_user_created on public.workout_plans (user_id, created_at desc);
create index if not exists idx_workout_sessions_user     on public.workout_sessions (user_id, created_at desc);
create index if not exists idx_workout_sessions_plan     on public.workout_sessions (workout_plan_id);
create index if not exists idx_cardio_user_performed     on public.cardio_sessions (user_id, performed_at desc);
create index if not exists idx_weight_user_created       on public.weight_history (user_id, created_at desc);
create index if not exists idx_measurements_user_created on public.body_measurements (user_id, created_at desc);
create index if not exists idx_photos_user_type          on public.progress_photos (user_id, photo_type, created_at desc);
create index if not exists idx_prs_user_exercise         on public.personal_records (user_id, exercise_id);
create index if not exists idx_ai_conv_user_created      on public.ai_conversations (user_id, created_at desc);
create index if not exists idx_notifications_user        on public.notifications (user_id, scheduled_at desc);
create index if not exists idx_weekly_goals_user_week    on public.weekly_goals (user_id, week_start desc);
create index if not exists idx_settings_user             on public.settings (user_id);
create index if not exists idx_exercise_library_muscle   on public.exercise_library (primary_muscle);
create index if not exists idx_exercise_library_slug     on public.exercise_library (slug);

-- Tabelas-filhas (ownership via pai) — acelera os EXISTS das políticas.
create index if not exists idx_workout_days_plan         on public.workout_days (workout_plan_id);
create index if not exists idx_workout_exercises_day     on public.workout_exercises (workout_day_id);
create index if not exists idx_exercise_sets_session     on public.exercise_sets (workout_session_id);

-- ---------------------------------------------------------------------
-- 3. RLS + políticas por usuário
--    Regra (09_SUPABASE_SQL): o usuário só lê/insere/atualiza os
--    próprios dados; nunca acessa dados de outro usuário; sem DELETE.
--    Leituras respeitam soft delete (deleted_at is null).
-- ---------------------------------------------------------------------

-- 3a. Tabela users (id == auth.uid()).
alter table public.users enable row level security;
drop policy if exists users_select_own on public.users;
drop policy if exists users_insert_own on public.users;
drop policy if exists users_update_own on public.users;
create policy users_select_own on public.users
  for select using (id = auth.uid());
create policy users_insert_own on public.users
  for insert with check (id = auth.uid());
create policy users_update_own on public.users
  for update using (id = auth.uid()) with check (id = auth.uid());

-- 3b. Tabelas com coluna user_id — políticas padronizadas via loop.
--     (Se a tabela tiver deleted_at, o SELECT filtra soft delete.)
do $$
declare
  tbl text;
  has_deleted boolean;
  owned text[] := array[
    'workout_plans','workout_sessions','cardio_sessions','body_measurements',
    'weight_history','progress_photos','ai_conversations','ai_memory',
    'personal_records','user_achievements','weekly_goals','notifications',
    'settings','ai_workout_generations','ai_workout_feedback'
  ];
begin
  foreach tbl in array owned loop
    execute format('alter table public.%I enable row level security;', tbl);

    select exists(
      select 1 from information_schema.columns
      where table_schema='public' and table_name=tbl and column_name='deleted_at'
    ) into has_deleted;

    execute format('drop policy if exists %I on public.%I;', tbl||'_select_own', tbl);
    execute format('drop policy if exists %I on public.%I;', tbl||'_insert_own', tbl);
    execute format('drop policy if exists %I on public.%I;', tbl||'_update_own', tbl);

    -- SELECT: só o dono; oculta soft-deletados quando aplicável.
    if has_deleted then
      execute format(
        'create policy %I on public.%I for select '
        'using (user_id = auth.uid() and deleted_at is null);',
        tbl||'_select_own', tbl);
    else
      execute format(
        'create policy %I on public.%I for select using (user_id = auth.uid());',
        tbl||'_select_own', tbl);
    end if;

    execute format(
      'create policy %I on public.%I for insert with check (user_id = auth.uid());',
      tbl||'_insert_own', tbl);
    execute format(
      'create policy %I on public.%I for update using (user_id = auth.uid()) '
      'with check (user_id = auth.uid());',
      tbl||'_update_own', tbl);
    -- Sem política de DELETE: DELETE físico fica bloqueado (soft delete apenas).
  end loop;
end $$;

-- 3c. Tabelas-filhas: ownership herdada do pai via EXISTS.
alter table public.workout_days enable row level security;
drop policy if exists workout_days_rw on public.workout_days;
create policy workout_days_rw on public.workout_days
  using (exists (
    select 1 from public.workout_plans p
    where p.id = workout_days.workout_plan_id and p.user_id = auth.uid()))
  with check (exists (
    select 1 from public.workout_plans p
    where p.id = workout_days.workout_plan_id and p.user_id = auth.uid()));

alter table public.workout_exercises enable row level security;
drop policy if exists workout_exercises_rw on public.workout_exercises;
create policy workout_exercises_rw on public.workout_exercises
  using (exists (
    select 1 from public.workout_days d
    join public.workout_plans p on p.id = d.workout_plan_id
    where d.id = workout_exercises.workout_day_id and p.user_id = auth.uid()))
  with check (exists (
    select 1 from public.workout_days d
    join public.workout_plans p on p.id = d.workout_plan_id
    where d.id = workout_exercises.workout_day_id and p.user_id = auth.uid()));

alter table public.exercise_sets enable row level security;
drop policy if exists exercise_sets_rw on public.exercise_sets;
create policy exercise_sets_rw on public.exercise_sets
  using (exists (
    select 1 from public.workout_sessions s
    where s.id = exercise_sets.workout_session_id and s.user_id = auth.uid()))
  with check (exists (
    select 1 from public.workout_sessions s
    where s.id = exercise_sets.workout_session_id and s.user_id = auth.uid()));

-- 3d. Catálogos globais: leitura pública autenticada, escrita bloqueada
--     ao cliente (populados por processo administrativo / service_role).
alter table public.exercise_library enable row level security;
drop policy if exists exercise_library_read on public.exercise_library;
create policy exercise_library_read on public.exercise_library
  for select using (auth.role() = 'authenticated');

alter table public.achievements enable row level security;
drop policy if exists achievements_read on public.achievements;
create policy achievements_read on public.achievements
  for select using (auth.role() = 'authenticated');

-- ---------------------------------------------------------------------
-- 4. Storage: buckets privados + políticas por usuário
--    Convenção de path: <bucket>/<auth.uid()>/<arquivo> — o primeiro
--    segmento do path é o dono. URLs sempre assinadas (client já usa
--    createSignedUrl).
-- ---------------------------------------------------------------------
insert into storage.buckets (id, name, public)
values
  ('avatars','avatars', false),
  ('exercise_images','exercise_images', false),
  ('exercise_gifs','exercise_gifs', false),
  ('exercise_videos','exercise_videos', false),
  ('progress_photos','progress_photos', false),
  ('meal_photos','meal_photos', false)
on conflict (id) do nothing;

-- Buckets de conteúdo do usuário: só o dono acessa (path[1] = uid).
do $$
declare
  b text;
  user_buckets text[] := array['avatars','progress_photos','meal_photos'];
begin
  foreach b in array user_buckets loop
    execute format('drop policy if exists %I on storage.objects;', b||'_own_read');
    execute format('drop policy if exists %I on storage.objects;', b||'_own_write');
    execute format('drop policy if exists %I on storage.objects;', b||'_own_update');
    execute format('drop policy if exists %I on storage.objects;', b||'_own_delete');

    execute format($f$
      create policy %I on storage.objects for select
      using (bucket_id = %L and (storage.foldername(name))[1] = auth.uid()::text);
    $f$, b||'_own_read', b);
    execute format($f$
      create policy %I on storage.objects for insert
      with check (bucket_id = %L and (storage.foldername(name))[1] = auth.uid()::text);
    $f$, b||'_own_write', b);
    execute format($f$
      create policy %I on storage.objects for update
      using (bucket_id = %L and (storage.foldername(name))[1] = auth.uid()::text);
    $f$, b||'_own_update', b);
    execute format($f$
      create policy %I on storage.objects for delete
      using (bucket_id = %L and (storage.foldername(name))[1] = auth.uid()::text);
    $f$, b||'_own_delete', b);
  end loop;
end $$;

-- Catálogos de mídia de exercícios: leitura para autenticados.
do $$
declare
  b text;
  catalog_buckets text[] := array['exercise_images','exercise_gifs','exercise_videos'];
begin
  foreach b in array catalog_buckets loop
    execute format('drop policy if exists %I on storage.objects;', b||'_read');
    execute format($f$
      create policy %I on storage.objects for select
      using (bucket_id = %L and auth.role() = 'authenticated');
    $f$, b||'_read', b);
  end loop;
end $$;

-- =====================================================================
-- Fim do baseline. Views (dashboard_summary, weekly_volume, muscle_balance,
-- exercise_prs, body_progress) e funções SQL (calculate_training_volume,
-- calculate_estimated_1rm, streak_days, weekly_sets, monthly_progress,
-- ai_context) permanecem como próximo passo — hoje calculadas no cliente.
-- =====================================================================
