-- =====================================================================
-- VIS — Schema base (tabelas) — 03_DATABASE.md
--
-- Rode ESTE arquivo PRIMEIRO, antes de 0001 e 0002.
-- Convenções: UUID em todas as tabelas, created_at/updated_at, e
-- deleted_at (soft delete) nas tabelas de histórico. Nada é apagado
-- fisicamente.
-- =====================================================================

-- gen_random_uuid() vem da extensão pgcrypto (já habilitada no Supabase).
create extension if not exists pgcrypto;

-- ---------- users (id = auth.users.id) ----------
create table if not exists public.users (
  id uuid primary key references auth.users(id) on delete cascade,
  name text,
  email text,
  photo_url text,
  birth_date date,
  height numeric,
  current_weight numeric,
  goal text,
  experience_level text,
  training_location text,
  preferred_theme text,
  onboarding_completed boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Cria a linha em public.users automaticamente quando um usuário se
-- cadastra no Supabase Auth (senão o UPDATE do onboarding não acha a linha).
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.users (id, email, name)
  values (new.id, new.email, coalesce(new.raw_user_meta_data->>'name', ''))
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------- Treino ----------
create table if not exists public.workout_plans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  description text,
  goal text,
  is_active boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.workout_days (
  id uuid primary key default gen_random_uuid(),
  workout_plan_id uuid not null references public.workout_plans(id) on delete cascade,
  day_name text not null,
  order_index int not null default 0,
  estimated_duration int,
  created_at timestamptz not null default now()
);

create table if not exists public.exercise_library (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text unique,
  description text,
  primary_muscle text,
  secondary_muscles text[],
  equipment text,
  difficulty text,
  exercise_type text,
  video_url text,
  gif_url text,
  photo_url text,
  execution text,
  breathing text,
  tempo text,
  common_errors text,
  tips text,
  variations text[],
  alternatives text[],
  created_at timestamptz not null default now()
);

create table if not exists public.workout_exercises (
  id uuid primary key default gen_random_uuid(),
  workout_day_id uuid not null references public.workout_days(id) on delete cascade,
  exercise_id uuid references public.exercise_library(id),
  order_index int not null default 0,
  sets int,
  target_reps text,
  target_rpe numeric,
  rest_seconds int,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.workout_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  workout_plan_id uuid references public.workout_plans(id),
  plan_name text,
  day_name text,
  started_at timestamptz not null default now(),
  finished_at timestamptz,
  duration int,
  total_volume numeric,
  total_sets int,
  total_exercises int,
  notes text,
  feeling text,
  created_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.exercise_sets (
  id uuid primary key default gen_random_uuid(),
  workout_session_id uuid not null references public.workout_sessions(id) on delete cascade,
  exercise_id uuid references public.exercise_library(id),
  set_number int,
  weight numeric,
  repetitions int,
  rpe numeric,
  rest_seconds int,
  set_type text,
  completed boolean not null default false,
  created_at timestamptz not null default now()
);

-- ---------- Cardio ----------
create table if not exists public.cardio_sessions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  type text,
  distance numeric,
  duration int,
  speed numeric,
  incline numeric,
  calories numeric,
  notes text,
  performed_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  deleted_at timestamptz
);

-- ---------- Evolução corporal ----------
create table if not exists public.body_measurements (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  neck numeric, shoulders numeric, chest numeric, waist numeric,
  abdomen numeric, hips numeric, glutes numeric,
  right_arm numeric, left_arm numeric,
  right_forearm numeric, left_forearm numeric,
  right_thigh numeric, left_thigh numeric,
  right_calf numeric, left_calf numeric,
  created_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.weight_history (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  weight numeric not null,
  body_fat numeric,
  muscle_mass numeric,
  visceral_fat numeric,
  observation text,
  created_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.progress_photos (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  photo_type text,
  storage_path text,
  thumbnail text,
  notes text,
  created_at timestamptz not null default now(),
  deleted_at timestamptz
);

-- ---------- IA ----------
create table if not exists public.ai_conversations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  question text,
  answer text,
  context_json jsonb,
  tokens int,
  created_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.ai_memory (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references auth.users(id) on delete cascade,
  favorite_exercises text[],
  disliked_exercises text[],
  injuries text,
  limitations text,
  available_equipment text[],
  preferred_training_time text,
  training_days int,
  goal text,
  last_analysis timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.ai_workout_generations (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  goal text,
  request jsonb,
  workout jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.ai_workout_feedback (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  workout_name text,
  rating text,
  comment text,
  created_at timestamptz not null default now()
);

-- ---------- Gamificação / metas / sistema ----------
create table if not exists public.personal_records (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  exercise_id uuid references public.exercise_library(id),
  weight numeric,
  repetitions int,
  estimated_1rm numeric,
  achieved_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create table if not exists public.achievements (
  id uuid primary key default gen_random_uuid(),
  title text,
  description text,
  icon text,
  xp int,
  category text,
  created_at timestamptz not null default now()
);

create table if not exists public.user_achievements (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  achievement_id uuid references public.achievements(id),
  earned_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create table if not exists public.weekly_goals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  target_workouts int,
  target_cardio int,
  target_weight numeric,
  target_water int,
  target_protein int,
  week_start date,
  created_at timestamptz not null default now()
);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text,
  body text,
  type text,
  read boolean not null default false,
  scheduled_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.settings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references auth.users(id) on delete cascade,
  theme text,
  language text,
  notifications_enabled boolean default true,
  measurement_unit text,
  weight_unit text,
  distance_unit text,
  rest_timer_sound boolean default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- =====================================================================
-- Próximo: rode 0001 (RLS + índices + storage) e depois 0002 (views).
-- =====================================================================
