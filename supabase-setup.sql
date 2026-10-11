-- PORTAL DE CLIENTES – Martinez & Asoc. | Pegar en Supabase > SQL Editor > Run (una vez)
create table if not exists public.profiles (
  id uuid primary key references auth.users on delete cascade,
  name text, cuit text, email text,
  role text not null default 'client' check (role in ('client','admin'))
);
create table if not exists public.documents (
  id bigint generated always as identity primary key,
  owner uuid not null references public.profiles(id) on delete cascade,
  name text not null, cat text, period text,
  by_studio boolean not null default false, size bigint, path text not null,
  seen boolean not null default false, created_at timestamptz not null default now()
);
create index if not exists documents_owner_idx on public.documents(owner);

create or replace function public.is_admin() returns boolean
language sql security definer stable set search_path = public as $$
  select exists (select 1 from public.profiles where id = auth.uid() and role = 'admin');
$$;

create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, name, cuit, email)
  values (new.id, coalesce(new.raw_user_meta_data->>'name', new.email), new.raw_user_meta_data->>'cuit', new.email);
  return new;
end $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute function public.handle_new_user();

alter table public.profiles enable row level security;
alter table public.documents enable row level security;
drop policy if exists "perfiles_ver" on public.profiles;
drop policy if exists "perfiles_admin" on public.profiles;
create policy "perfiles_ver" on public.profiles for select using (id = auth.uid() or public.is_admin());
create policy "perfiles_admin" on public.profiles for update using (public.is_admin());
drop policy if exists "docs_ver" on public.documents;
drop policy if exists "docs_subir" on public.documents;
drop policy if exists "docs_marcar" on public.documents;
drop policy if exists "docs_borrar" on public.documents;
create policy "docs_ver" on public.documents for select using (owner = auth.uid() or public.is_admin());
create policy "docs_subir" on public.documents for insert with check ((owner = auth.uid() and by_studio = false) or public.is_admin());
create policy "docs_marcar" on public.documents for update using (public.is_admin());
create policy "docs_borrar" on public.documents for delete using (public.is_admin() or (owner = auth.uid() and by_studio = false));

insert into storage.buckets (id, name, public, file_size_limit) values ('documentos','documentos',false,20971520) on conflict (id) do nothing;
drop policy if exists "archivos_ver" on storage.objects;
drop policy if exists "archivos_subir" on storage.objects;
drop policy if exists "archivos_borrar" on storage.objects;
create policy "archivos_ver" on storage.objects for select using (bucket_id='documentos' and ((storage.foldername(name))[1] = auth.uid()::text or public.is_admin()));
create policy "archivos_subir" on storage.objects for insert with check (bucket_id='documentos' and ((storage.foldername(name))[1] = auth.uid()::text or public.is_admin()));
create policy "archivos_borrar" on storage.objects for delete using (bucket_id='documentos' and ((storage.foldername(name))[1] = auth.uid()::text or public.is_admin()));

-- Después de crear el usuario del estudio (LEEME paso 2.4), ejecutar cambiando el e-mail:
-- update public.profiles set role = 'admin', name = 'Estudio Martinez & Asoc.' where email = 'CORREO-DEL-ESTUDIO@ejemplo.com';
