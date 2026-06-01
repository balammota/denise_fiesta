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

-- ═══════════════════════════════════════════════════════════
-- Mensajes para Denise
-- ═══════════════════════════════════════════════════════════

create table if not exists public.picnic_messages (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  message text not null check (char_length(message) <= 800),
  created_at timestamptz not null default now()
);

create index if not exists picnic_messages_created_at_idx
  on public.picnic_messages (created_at desc);

alter table public.picnic_messages enable row level security;

drop policy if exists "picnic_messages_select" on public.picnic_messages;
drop policy if exists "picnic_messages_insert" on public.picnic_messages;

create policy "picnic_messages_select"
  on public.picnic_messages for select
  to anon, authenticated
  using (true);

create policy "picnic_messages_insert"
  on public.picnic_messages for insert
  to anon, authenticated
  with check (true);

-- ═══════════════════════════════════════════════════════════
-- Fotos del picnic (Storage)
-- Crea el bucket en Dashboard → Storage si el insert falla
-- ═══════════════════════════════════════════════════════════

insert into storage.buckets (id, name, public)
values ('picnic-photos', 'picnic-photos', true)
on conflict (id) do update set public = true;

drop policy if exists "picnic_photos_select" on storage.objects;
drop policy if exists "picnic_photos_insert" on storage.objects;

create policy "picnic_photos_select"
  on storage.objects for select
  to anon, authenticated
  using (bucket_id = 'picnic-photos');

create policy "picnic_photos_insert"
  on storage.objects for insert
  to anon, authenticated
  with check (bucket_id = 'picnic-photos');
