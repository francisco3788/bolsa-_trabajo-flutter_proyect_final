-- =====================================================
-- SCRIPT DE LIMPIEZA COMPLETA Y RECREACIÓN
-- =====================================================
-- Este script limpia completamente la base de datos y 
-- la recrea con la estructura correcta para la aplicación

-- =====================================================
-- PASO 1: LIMPIAR TODO
-- =====================================================

-- Eliminar todas las políticas RLS
DROP POLICY IF EXISTS jobs_select_public ON public.jobs;
DROP POLICY IF EXISTS jobs_select_owner ON public.jobs;
DROP POLICY IF EXISTS jobs_insert_company ON public.jobs;
DROP POLICY IF EXISTS jobs_update_owner ON public.jobs;
DROP POLICY IF EXISTS jobs_delete_owner ON public.jobs;

DROP POLICY IF EXISTS applications_select_candidate ON public.applications;
DROP POLICY IF EXISTS applications_select_company ON public.applications;
DROP POLICY IF EXISTS applications_insert_candidate ON public.applications;
DROP POLICY IF EXISTS applications_update_company ON public.applications;

DROP POLICY IF EXISTS saved_jobs_select_owner ON public.saved_jobs;
DROP POLICY IF EXISTS saved_jobs_insert_owner ON public.saved_jobs;
DROP POLICY IF EXISTS saved_jobs_delete_owner ON public.saved_jobs;

-- Eliminar vistas
DROP VIEW IF EXISTS public.jobs_with_stats;

-- Eliminar tablas (en orden correcto por dependencias)
DROP TABLE IF EXISTS public.saved_jobs;
DROP TABLE IF EXISTS public.applications;
DROP TABLE IF EXISTS public.jobs;
DROP TABLE IF EXISTS public.company_profiles;
DROP TABLE IF EXISTS public.candidate_profiles;
DROP TABLE IF EXISTS public.user_roles;

-- =====================================================
-- PASO 2: RECREAR TABLAS
-- =====================================================

-- Tabla de roles de usuario
CREATE TABLE public.user_roles (
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    role TEXT NOT NULL CHECK (role IN ('candidate', 'company')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de perfiles de candidatos
CREATE TABLE public.candidate_profiles (
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    name TEXT NOT NULL,
    location TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de perfiles de empresas
CREATE TABLE public.company_profiles (
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE PRIMARY KEY,
    company_name TEXT NOT NULL,
    sector TEXT NOT NULL,
    location TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de trabajos
CREATE TABLE public.jobs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    company_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    company_name TEXT NOT NULL,
    location TEXT NOT NULL,
    work_mode TEXT NOT NULL CHECK (work_mode IN ('remote', 'hybrid', 'onsite')),
    job_type TEXT NOT NULL CHECK (job_type IN ('full_time', 'part_time', 'contract', 'internship')),
    salary_min INTEGER,
    salary_max INTEGER,
    currency TEXT DEFAULT 'USD',
    skills TEXT[] DEFAULT '{}',
    requirements TEXT,
    benefits TEXT,
    status TEXT NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'pending', 'closed')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tabla de postulaciones
CREATE TABLE public.applications (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    job_id UUID REFERENCES public.jobs(id) ON DELETE CASCADE NOT NULL,
    candidate_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    cover_letter TEXT,
    status TEXT NOT NULL DEFAULT 'submitted' CHECK (status IN ('submitted', 'reviewing', 'interview', 'rejected', 'accepted')),
    applied_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(job_id, candidate_id)
);

-- Tabla de trabajos guardados
CREATE TABLE public.saved_jobs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    candidate_id UUID REFERENCES auth.users(id) ON DELETE CASCADE NOT NULL,
    job_id UUID REFERENCES public.jobs(id) ON DELETE CASCADE NOT NULL,
    saved_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(candidate_id, job_id)
);

-- =====================================================
-- PASO 3: CREAR ÍNDICES
-- =====================================================

-- Índices para jobs
CREATE INDEX idx_jobs_company_id ON public.jobs(company_id);
CREATE INDEX idx_jobs_status ON public.jobs(status);
CREATE INDEX idx_jobs_created_at ON public.jobs(created_at DESC);
CREATE INDEX idx_jobs_work_mode ON public.jobs(work_mode);
CREATE INDEX idx_jobs_job_type ON public.jobs(job_type);

-- Índices para applications
CREATE INDEX idx_applications_job_id ON public.applications(job_id);
CREATE INDEX idx_applications_candidate_id ON public.applications(candidate_id);
CREATE INDEX idx_applications_status ON public.applications(status);
CREATE INDEX idx_applications_applied_at ON public.applications(applied_at DESC);

-- Índices para saved_jobs
CREATE INDEX idx_saved_jobs_candidate_id ON public.saved_jobs(candidate_id);
CREATE INDEX idx_saved_jobs_job_id ON public.saved_jobs(job_id);

-- =====================================================
-- PASO 4: CREAR VISTA jobs_with_stats
-- =====================================================

CREATE VIEW public.jobs_with_stats AS
SELECT 
    j.*,
    COALESCE(app_stats.total_applications, 0) as total_applications,
    COALESCE(app_stats.new_applications, 0) as new_applications
FROM public.jobs j
LEFT JOIN (
    SELECT 
        job_id,
        COUNT(*) as total_applications,
        COUNT(CASE WHEN applied_at >= NOW() - INTERVAL '7 days' THEN 1 END) as new_applications
    FROM public.applications
    GROUP BY job_id
) app_stats ON j.id = app_stats.job_id;

-- =====================================================
-- PASO 5: CONFIGURAR RLS (Row Level Security)
-- =====================================================

-- Habilitar RLS
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.candidate_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.company_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.jobs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_jobs ENABLE ROW LEVEL SECURITY;

-- Políticas para user_roles
CREATE POLICY user_roles_select_own ON public.user_roles FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY user_roles_insert_own ON public.user_roles FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY user_roles_update_own ON public.user_roles FOR UPDATE USING (auth.uid() = user_id);

-- Políticas para candidate_profiles
CREATE POLICY candidate_profiles_select_own ON public.candidate_profiles FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY candidate_profiles_insert_own ON public.candidate_profiles FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY candidate_profiles_update_own ON public.candidate_profiles FOR UPDATE USING (auth.uid() = user_id);

-- Políticas para company_profiles
CREATE POLICY company_profiles_select_own ON public.company_profiles FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY company_profiles_insert_own ON public.company_profiles FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY company_profiles_update_own ON public.company_profiles FOR UPDATE USING (auth.uid() = user_id);

-- Políticas para jobs
CREATE POLICY jobs_select_public ON public.jobs FOR SELECT USING (status = 'active');
CREATE POLICY jobs_select_owner ON public.jobs FOR SELECT USING (auth.uid() = company_id);
CREATE POLICY jobs_insert_company ON public.jobs FOR INSERT WITH CHECK (auth.uid() = company_id);
CREATE POLICY jobs_update_owner ON public.jobs FOR UPDATE USING (auth.uid() = company_id);
CREATE POLICY jobs_delete_owner ON public.jobs FOR DELETE USING (auth.uid() = company_id);

-- Políticas para applications
CREATE POLICY applications_select_candidate ON public.applications FOR SELECT USING (auth.uid() = candidate_id);
CREATE POLICY applications_select_company ON public.applications FOR SELECT USING (
    auth.uid() IN (SELECT company_id FROM public.jobs WHERE id = job_id)
);
CREATE POLICY applications_insert_candidate ON public.applications FOR INSERT WITH CHECK (auth.uid() = candidate_id);
CREATE POLICY applications_update_company ON public.applications FOR UPDATE USING (
    auth.uid() IN (SELECT company_id FROM public.jobs WHERE id = job_id)
);

-- Políticas para saved_jobs
CREATE POLICY saved_jobs_select_owner ON public.saved_jobs FOR SELECT USING (auth.uid() = candidate_id);
CREATE POLICY saved_jobs_insert_owner ON public.saved_jobs FOR INSERT WITH CHECK (auth.uid() = candidate_id);
CREATE POLICY saved_jobs_delete_owner ON public.saved_jobs FOR DELETE USING (auth.uid() = candidate_id);

-- =====================================================
-- MENSAJE DE CONFIRMACIÓN
-- =====================================================

SELECT 'Base de datos limpiada y recreada exitosamente!' as mensaje;