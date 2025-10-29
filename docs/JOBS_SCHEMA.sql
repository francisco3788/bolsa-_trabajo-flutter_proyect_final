-- =====================================================
-- ESQUEMA SQL PARA MVP BOLSA DE TRABAJO
-- =====================================================
-- Ejecutar en orden: (A) -> (B) -> (C)

-- =====================================================
-- (A) CREACIÓN DE TABLAS
-- =====================================================

-- Tabla de trabajos/ofertas
create table if not exists public.jobs (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  description text not null,
  company_name text not null,
  location text not null,
  work_mode text not null check (work_mode in ('remote', 'hybrid', 'onsite')),
  job_type text not null check (job_type in ('full_time', 'part_time', 'contract', 'internship')),
  salary_min integer,
  salary_max integer,
  currency text default 'USD',
  skills text[] not null default '{}',
  requirements text,
  benefits text,
  status text not null default 'active' check (status in ('active', 'pending', 'closed')),
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

-- Tabla de postulaciones
create table if not exists public.applications (
  id uuid primary key default gen_random_uuid(),
  job_id uuid not null references public.jobs(id) on delete cascade,
  candidate_id uuid not null references auth.users(id) on delete cascade,
  cover_letter text,
  status text not null default 'submitted' check (status in ('submitted', 'seen', 'interview', 'rejected', 'hired')),
  applied_at timestamptz default now(),
  updated_at timestamptz default now(),
  -- Constraint para evitar postulaciones duplicadas
  unique(job_id, candidate_id)
);

-- Tabla de trabajos guardados
create table if not exists public.saved_jobs (
  id uuid primary key default gen_random_uuid(),
  job_id uuid not null references public.jobs(id) on delete cascade,
  candidate_id uuid not null references auth.users(id) on delete cascade,
  saved_at timestamptz default now(),
  -- Constraint para evitar duplicados
  unique(job_id, candidate_id)
);

-- =====================================================
-- (B) ÍNDICES PARA OPTIMIZACIÓN
-- =====================================================

-- Índices para jobs
create index if not exists idx_jobs_company_id on public.jobs(company_id);
create index if not exists idx_jobs_status on public.jobs(status);
create index if not exists idx_jobs_created_at on public.jobs(created_at desc);
create index if not exists idx_jobs_location on public.jobs(location);
create index if not exists idx_jobs_work_mode on public.jobs(work_mode);
create index if not exists idx_jobs_job_type on public.jobs(job_type);

-- Índices para applications
create index if not exists idx_applications_job_id on public.applications(job_id);
create index if not exists idx_applications_candidate_id on public.applications(candidate_id);
create index if not exists idx_applications_status on public.applications(status);
create index if not exists idx_applications_applied_at on public.applications(applied_at desc);

-- Índices para saved_jobs
create index if not exists idx_saved_jobs_candidate_id on public.saved_jobs(candidate_id);
create index if not exists idx_saved_jobs_job_id on public.saved_jobs(job_id);

-- =====================================================
-- (C) ROW LEVEL SECURITY (RLS)
-- =====================================================

-- Habilitar RLS en todas las tablas
alter table public.jobs enable row level security;
alter table public.applications enable row level security;
alter table public.saved_jobs enable row level security;

-- =====================================================
-- POLÍTICAS PARA JOBS
-- =====================================================

-- Limpiar políticas existentes
drop policy if exists jobs_select_public on public.jobs;
drop policy if exists jobs_select_owner on public.jobs;
drop policy if exists jobs_insert_company on public.jobs;
drop policy if exists jobs_update_owner on public.jobs;
drop policy if exists jobs_delete_owner on public.jobs;

-- Lectura pública solo para trabajos activos
create policy jobs_select_public
on public.jobs for select
using (status = 'active');

-- Lectura completa para el dueño (empresa)
create policy jobs_select_owner
on public.jobs for select
using (company_id = auth.uid());

-- Solo empresas pueden crear trabajos
create policy jobs_insert_company
on public.jobs for insert
with check (
  company_id = auth.uid() 
  and exists (
    select 1 from public.user_roles 
    where user_id = auth.uid() and role = 'company'
  )
);

-- Solo el dueño puede actualizar
create policy jobs_update_owner
on public.jobs for update
using (company_id = auth.uid())
with check (company_id = auth.uid());

-- Solo el dueño puede eliminar
create policy jobs_delete_owner
on public.jobs for delete
using (company_id = auth.uid());

-- =====================================================
-- POLÍTICAS PARA APPLICATIONS
-- =====================================================

-- Limpiar políticas existentes
drop policy if exists applications_select_candidate on public.applications;
drop policy if exists applications_select_company on public.applications;
drop policy if exists applications_insert_candidate on public.applications;
drop policy if exists applications_update_candidate on public.applications;
drop policy if exists applications_update_company on public.applications;
drop policy if exists applications_delete_candidate on public.applications;

-- Candidatos pueden ver sus propias postulaciones
create policy applications_select_candidate
on public.applications for select
using (candidate_id = auth.uid());

-- Empresas pueden ver postulaciones a sus trabajos
create policy applications_select_company
on public.applications for select
using (
  exists (
    select 1 from public.jobs 
    where id = job_id and company_id = auth.uid()
  )
);

-- Solo candidatos pueden postularse
create policy applications_insert_candidate
on public.applications for insert
with check (
  candidate_id = auth.uid() 
  and exists (
    select 1 from public.user_roles 
    where user_id = auth.uid() and role = 'candidate'
  )
  and exists (
    select 1 from public.jobs 
    where id = job_id and status = 'active'
  )
);

-- Candidatos pueden actualizar sus postulaciones (ej: cover letter)
create policy applications_update_candidate
on public.applications for update
using (candidate_id = auth.uid())
with check (candidate_id = auth.uid());

-- Empresas pueden actualizar el estado de postulaciones a sus trabajos
create policy applications_update_company
on public.applications for update
using (
  exists (
    select 1 from public.jobs 
    where id = job_id and company_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from public.jobs 
    where id = job_id and company_id = auth.uid()
  )
);

-- Candidatos pueden eliminar sus postulaciones
create policy applications_delete_candidate
on public.applications for delete
using (candidate_id = auth.uid());

-- =====================================================
-- POLÍTICAS PARA SAVED_JOBS
-- =====================================================

-- Limpiar políticas existentes
drop policy if exists saved_jobs_all_candidate on public.saved_jobs;

-- Solo candidatos pueden gestionar sus trabajos guardados
create policy saved_jobs_all_candidate
on public.saved_jobs for all
using (candidate_id = auth.uid())
with check (
  candidate_id = auth.uid() 
  and exists (
    select 1 from public.user_roles 
    where user_id = auth.uid() and role = 'candidate'
  )
);

-- =====================================================
-- FUNCIONES AUXILIARES
-- =====================================================

-- Función para actualizar updated_at automáticamente
create or replace function update_updated_at_column()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

-- Triggers para actualizar updated_at
drop trigger if exists update_jobs_updated_at on public.jobs;
create trigger update_jobs_updated_at
  before update on public.jobs
  for each row execute function update_updated_at_column();

drop trigger if exists update_applications_updated_at on public.applications;
create trigger update_applications_updated_at
  before update on public.applications
  for each row execute function update_updated_at_column();

-- =====================================================
-- VISTAS PARA CONSULTAS OPTIMIZADAS
-- =====================================================

-- Vista para trabajos con información de postulaciones
create or replace view public.jobs_with_stats as
select 
  j.*,
  coalesce(app_stats.total_applications, 0) as total_applications,
  coalesce(app_stats.new_applications, 0) as new_applications
from public.jobs j
left join (
  select 
    job_id,
    count(*) as total_applications,
    count(*) filter (where status = 'submitted') as new_applications
  from public.applications
  group by job_id
) app_stats on j.id = app_stats.job_id;

-- =====================================================
-- DATOS DE PRUEBA (OPCIONAL)
-- =====================================================

-- Insertar algunos trabajos de ejemplo (solo si no existen)
-- Nota: Reemplazar los UUIDs con IDs reales de empresas en tu sistema

/*
insert into public.jobs (company_id, title, description, company_name, location, work_mode, job_type, skills, salary_min, salary_max)
values 
  ('company-uuid-1', 'Desarrollador Flutter Senior', 'Buscamos desarrollador Flutter con experiencia...', 'TechCorp', 'Madrid, España', 'hybrid', 'full_time', '{"Flutter", "Dart", "Firebase"}', 45000, 60000),
  ('company-uuid-2', 'Diseñador UX/UI', 'Únete a nuestro equipo de diseño...', 'DesignStudio', 'Barcelona, España', 'remote', 'full_time', '{"Figma", "Adobe XD", "Sketch"}', 35000, 50000)
on conflict do nothing;
*/

-- =====================================================
-- VERIFICACIÓN
-- =====================================================

-- Consultas para verificar que todo funciona
-- select * from public.jobs limit 5;
-- select * from public.applications limit 5;
-- select * from public.saved_jobs limit 5;
-- select * from public.jobs_with_stats limit 5;