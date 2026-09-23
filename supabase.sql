-- Jalankan seluruh SQL ini di Supabase > SQL Editor.
create extension if not exists pgcrypto;
create table if not exists public.profiles(id uuid primary key references auth.users(id) on delete cascade, full_name text, role text not null default 'warga' check(role in ('admin','warga')), created_at timestamptz default now());
create table if not exists public.residents(id uuid primary key default gen_random_uuid(), name text not null, nik text, address text, phone text, status text default 'aktif', created_at timestamptz default now());
create table if not exists public.transactions(id uuid primary key default gen_random_uuid(), date date not null default current_date, type text not null check(type in ('masuk','keluar')), category text default 'Lainnya', description text not null, amount numeric(15,2) not null check(amount>=0), created_by uuid references auth.users(id), created_at timestamptz default now());
create table if not exists public.loans(id uuid primary key default gen_random_uuid(), resident_id uuid not null references public.residents(id), principal numeric(15,2) not null check(principal>0), start_date date default current_date, notes text, created_by uuid references auth.users(id), created_at timestamptz default now());
create table if not exists public.installments(id uuid primary key default gen_random_uuid(), loan_id uuid not null references public.loans(id) on delete cascade, date date not null default current_date, amount numeric(15,2) not null check(amount>0), note text, created_by uuid references auth.users(id), created_at timestamptz default now());
create table if not exists public.settings(id boolean primary key default true, rt_name text default 'RT 01', rw_name text default 'RW 01', kelurahan text default '', kecamatan text default '', kabupaten text default '', kop_line text default 'LAPORAN KAS RT');
insert into public.settings(id) values(true) on conflict(id) do nothing;
create or replace function public.is_admin() returns boolean language sql stable security definer set search_path=public as $$ select exists(select 1 from public.profiles where id=auth.uid() and role='admin'); $$;
alter table public.profiles enable row level security; alter table public.residents enable row level security; alter table public.transactions enable row level security; alter table public.loans enable row level security; alter table public.installments enable row level security; alter table public.settings enable row level security;
-- Semua pengguna login boleh membaca.
create policy "profiles read own" on public.profiles for select using (auth.uid()=id or public.is_admin());
create policy "residents read" on public.residents for select to authenticated using (true);
create policy "transactions read" on public.transactions for select to authenticated using (true);
create policy "loans read" on public.loans for select to authenticated using (true);
create policy "installments read" on public.installments for select to authenticated using (true);
create policy "settings read" on public.settings for select to authenticated using (true);
-- Hanya admin boleh menambah/mengubah/menghapus pembukuan.
create policy "residents admin insert" on public.residents for insert to authenticated with check(public.is_admin());
create policy "residents admin update" on public.residents for update to authenticated using(public.is_admin()) with check(public.is_admin());
create policy "residents admin delete" on public.residents for delete to authenticated using(public.is_admin());
create policy "transactions admin insert" on public.transactions for insert to authenticated with check(public.is_admin());
create policy "transactions admin update" on public.transactions for update to authenticated using(public.is_admin()) with check(public.is_admin());
create policy "transactions admin delete" on public.transactions for delete to authenticated using(public.is_admin());
create policy "loans admin insert" on public.loans for insert to authenticated with check(public.is_admin());
create policy "loans admin update" on public.loans for update to authenticated using(public.is_admin()) with check(public.is_admin());
create policy "loans admin delete" on public.loans for delete to authenticated using(public.is_admin());
create policy "installments admin insert" on public.installments for insert to authenticated with check(public.is_admin());
create policy "installments admin update" on public.installments for update to authenticated using(public.is_admin()) with check(public.is_admin());
create policy "installments admin delete" on public.installments for delete to authenticated using(public.is_admin());
create policy "settings admin update" on public.settings for update to authenticated using(public.is_admin()) with check(public.is_admin());
-- Setelah membuat user admin di Authentication > Users, jalankan:
-- update public.profiles set role='admin' where id='UUID_USER_ADMIN';
-- Buat profil otomatis untuk user baru (default warga).
create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$ begin insert into public.profiles(id,full_name) values(new.id,coalesce(new.raw_user_meta_data->>'full_name','')); return new; end; $$;
drop trigger if exists on_auth_user_created on auth.users; create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();
