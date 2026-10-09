-- Unify Easy: stockage privé de l'état de l'application par compte connecté.
-- Exécuter dans Supabase > SQL Editor > New query.
create table if not exists public.app_state (
  user_id uuid primary key references auth.users(id) on delete cascade,
  payload jsonb not null default '{"role":"admin","responsible":[],"team":[],"events":[],"feedbackEvent":null}'::jsonb,
  updated_at timestamptz not null default now()
);

alter table public.app_state enable row level security;

-- Chaque compte ne peut lire, créer ou modifier que ses propres données.
drop policy if exists "Users can read their own app state" on public.app_state;
create policy "Users can read their own app state"
  on public.app_state for select to authenticated
  using (auth.uid() = user_id);

drop policy if exists "Users can create their own app state" on public.app_state;
create policy "Users can create their own app state"
  on public.app_state for insert to authenticated
  with check (auth.uid() = user_id);

drop policy if exists "Users can update their own app state" on public.app_state;
create policy "Users can update their own app state"
  on public.app_state for update to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

grant select, insert, update on public.app_state to authenticated;
revoke all on public.app_state from anon;
