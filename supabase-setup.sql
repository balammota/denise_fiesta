-- Ejecuta esto en Supabase → SQL Editor → Run
-- Picnic Denise: tabla de RSVPs + realtime

create table if not exists public.picnic_rsvps (
  id text primary key,
  name text not null,
  guest_count integer not null default 1 check (guest_count >= 1),
  items jsonb not null default '{}',
  updated_at timestamptz not null default now()
);

create index if not exists picnic_rsvps_updated_at_idx
  on public.picnic_rsvps (updated_at desc);

alter table public.picnic_rsvps enable row level security;

drop policy if exists "picnic_rsvps_select" on public.picnic_rsvps;
drop policy if exists "picnic_rsvps_insert" on public.picnic_rsvps;
drop policy if exists "picnic_rsvps_update" on public.picnic_rsvps;

create policy "picnic_rsvps_select"
  on public.picnic_rsvps for select
  to anon, authenticated
  using (true);

create policy "picnic_rsvps_insert"
  on public.picnic_rsvps for insert
  to anon, authenticated
  with check (true);

create policy "picnic_rsvps_update"
  on public.picnic_rsvps for update
  to anon, authenticated
  using (true)
  with check (true);

-- Realtime (si falla, activa la tabla en Database → Replication)
alter publication supabase_realtime add table public.picnic_rsvps;
