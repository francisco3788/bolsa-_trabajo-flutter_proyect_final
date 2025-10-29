# Supabase Setup

## SQL obligatorio

### (A) Tabla de roles

```sql
create table if not exists public.user_roles (
  id uuid primary key references auth.users(id) on delete cascade,
  role text not null check (role in ('candidate','company')),
  chosen_at timestamptz default now()
);

alter table public.user_roles enable row level security;

drop policy if exists ur_select on public.user_roles;
drop policy if exists ur_upsert on public.user_roles;

create policy ur_select
on public.user_roles for select
using (auth.uid() = id);

create policy ur_upsert
on public.user_roles for all
using (auth.uid() = id)
with check (auth.uid() = id);
```

### (B) Perfil CANDIDATO (mínimos: nombre, ubicación)

```sql
create table if not exists public.candidate_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  name text not null,
  location text not null,           -- "Ciudad, País"
  updated_at timestamptz default now()
);

alter table public.candidate_profiles enable row level security;

drop policy if exists cp_select on public.candidate_profiles;
drop policy if exists cp_upsert on public.candidate_profiles;

create policy cp_select
on public.candidate_profiles for select
using (auth.uid() = id);

create policy cp_upsert
on public.candidate_profiles for all
using (auth.uid() = id)
with check (auth.uid() = id);
```

### (C) Perfil EMPRESA (mínimos: nombre empresa, sector, ubicación)

```sql
create table if not exists public.company_profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  company_name text not null,       -- Puede ser nombre legal o comercial
  sector text not null,             -- "Tecnología", "Educación", "Salud", etc.
  location text not null,           -- "Ciudad, País"
  updated_at timestamptz default now()
);

alter table public.company_profiles enable row level security;

drop policy if exists comp_select on public.company_profiles;
drop policy if exists comp_upsert on public.company_profiles;

create policy comp_select
on public.company_profiles for select
using (auth.uid() = id);

create policy comp_upsert
on public.company_profiles for all
using (auth.uid() = id)
with check (auth.uid() = id);
```

## Orden de ejecución

1. Ejecutar el bloque (A).
2. Ejecutar el bloque (B).
3. Ejecutar el bloque (C).

## Consultas de verificación

```sql
select * from public.user_roles limit 1;
select * from public.candidate_profiles limit 1;
select * from public.company_profiles limit 1;
```
