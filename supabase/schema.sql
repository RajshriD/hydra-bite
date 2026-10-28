-- Run once in Supabase SQL Editor.
create extension if not exists pgcrypto;
create table if not exists public.profiles(
 id uuid primary key references auth.users(id) on delete cascade,
 daily_goal_ml integer not null default 2000 check(daily_goal_ml between 250 and 10000),
 reminder_enabled boolean not null default true,
 created_at timestamptz not null default now()
);
create table if not exists public.water_logs(
 id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
 amount_ml integer not null check(amount_ml between 1 and 5000), logged_at timestamptz not null default now()
);
create index if not exists water_logs_user_time_idx on public.water_logs(user_id,logged_at desc);
create table if not exists public.meal_logs(
 id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
 meal_name text not null check(char_length(meal_name) between 1 and 120), logged_at timestamptz not null default now()
);
create index if not exists meal_logs_user_time_idx on public.meal_logs(user_id,logged_at desc);
create table if not exists public.reminder_schedules(
 id uuid primary key default gen_random_uuid(), user_id uuid not null references auth.users(id) on delete cascade,
 label text not null check(char_length(label) between 1 and 100), reminder_time time not null,
 reminder_type text not null check(reminder_type in ('meal','water')), enabled boolean not null default true,
 created_at timestamptz not null default now()
);
create index if not exists reminders_user_time_idx on public.reminder_schedules(user_id,reminder_time);
alter table public.profiles enable row level security;
alter table public.water_logs enable row level security;
alter table public.meal_logs enable row level security;
alter table public.reminder_schedules enable row level security;
drop policy if exists profile_select_own on public.profiles;
create policy profile_select_own on public.profiles for select to authenticated using(auth.uid()=id);
drop policy if exists profile_insert_own on public.profiles;
create policy profile_insert_own on public.profiles for insert to authenticated with check(auth.uid()=id);
drop policy if exists profile_update_own on public.profiles;
create policy profile_update_own on public.profiles for update to authenticated using(auth.uid()=id) with check(auth.uid()=id);
drop policy if exists water_own on public.water_logs;
create policy water_own on public.water_logs for all to authenticated using(auth.uid()=user_id) with check(auth.uid()=user_id);
drop policy if exists meals_own on public.meal_logs;
create policy meals_own on public.meal_logs for all to authenticated using(auth.uid()=user_id) with check(auth.uid()=user_id);
drop policy if exists reminders_own on public.reminder_schedules;
create policy reminders_own on public.reminder_schedules for all to authenticated using(auth.uid()=user_id) with check(auth.uid()=user_id);
create or replace function public.hydrabite_new_user() returns trigger language plpgsql security definer set search_path='' as $$ begin insert into public.profiles(id) values(new.id) on conflict(id) do nothing; return new; end; $$;
drop trigger if exists hydrabite_auth_user_created on auth.users;
create trigger hydrabite_auth_user_created after insert on auth.users for each row execute procedure public.hydrabite_new_user();
revoke all on public.profiles from anon; revoke all on public.water_logs from anon; revoke all on public.meal_logs from anon; revoke all on public.reminder_schedules from anon;
grant select,insert,update on public.profiles to authenticated;
grant select,insert,update,delete on public.water_logs to authenticated;
grant select,insert,update,delete on public.meal_logs to authenticated;
grant select,insert,update,delete on public.reminder_schedules to authenticated;
