-- =====================================================
-- SCRIPT COMPLETO PARA CORREGIR TODAS LAS TABLAS
-- =====================================================
-- Este script corrige user_roles, candidate_profiles y company_profiles
-- para usar 'id' en lugar de 'user_id' como espera la aplicación Flutter

-- =====================================================
-- PASO 1: ELIMINAR TODAS LAS TABLAS PROBLEMÁTICAS
-- =====================================================

-- Eliminar políticas RLS existentes
DROP POLICY IF EXISTS "Users can view their own role" ON public.user_roles;
DROP POLICY IF EXISTS "Users can insert their own role" ON public.user_roles;
DROP POLICY IF EXISTS "Users can update their own role" ON public.user_roles;

DROP POLICY IF EXISTS "candidate_profiles_select_own" ON public.candidate_profiles;
DROP POLICY IF EXISTS "candidate_profiles_insert_own" ON public.candidate_profiles;
DROP POLICY IF EXISTS "candidate_profiles_update_own" ON public.candidate_profiles;

DROP POLICY IF EXISTS "company_profiles_select_own" ON public.company_profiles;
DROP POLICY IF EXISTS "company_profiles_insert_own" ON public.company_profiles;
DROP POLICY IF EXISTS "company_profiles_update_own" ON public.company_profiles;

-- Eliminar las tablas
DROP TABLE IF EXISTS public.user_roles CASCADE;
DROP TABLE IF EXISTS public.candidate_profiles CASCADE;
DROP TABLE IF EXISTS public.company_profiles CASCADE;

-- =====================================================
-- PASO 2: CREAR TABLA USER_ROLES CON 'ID'
-- =====================================================

CREATE TABLE public.user_roles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('candidate', 'company')),
    chosen_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Habilitar RLS
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

-- Políticas RLS para user_roles
CREATE POLICY "Users can view their own role" ON public.user_roles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can insert their own role" ON public.user_roles
    FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update their own role" ON public.user_roles
    FOR UPDATE USING (auth.uid() = id);

-- Índices para user_roles
CREATE INDEX idx_user_roles_id ON public.user_roles(id);
CREATE INDEX idx_user_roles_role ON public.user_roles(role);

-- =====================================================
-- PASO 3: CREAR TABLA CANDIDATE_PROFILES CON 'ID'
-- =====================================================

CREATE TABLE public.candidate_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    location TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Habilitar RLS
ALTER TABLE public.candidate_profiles ENABLE ROW LEVEL SECURITY;

-- Políticas RLS para candidate_profiles
CREATE POLICY "candidate_profiles_select_own" ON public.candidate_profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "candidate_profiles_insert_own" ON public.candidate_profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "candidate_profiles_update_own" ON public.candidate_profiles
    FOR UPDATE USING (auth.uid() = id);

-- Índices para candidate_profiles
CREATE INDEX idx_candidate_profiles_id ON public.candidate_profiles(id);

-- =====================================================
-- PASO 4: CREAR TABLA COMPANY_PROFILES CON 'ID'
-- =====================================================

CREATE TABLE public.company_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    company_name TEXT NOT NULL,
    sector TEXT NOT NULL,
    location TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Habilitar RLS
ALTER TABLE public.company_profiles ENABLE ROW LEVEL SECURITY;

-- Políticas RLS para company_profiles
CREATE POLICY "company_profiles_select_own" ON public.company_profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "company_profiles_insert_own" ON public.company_profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "company_profiles_update_own" ON public.company_profiles
    FOR UPDATE USING (auth.uid() = id);

-- Índices para company_profiles
CREATE INDEX idx_company_profiles_id ON public.company_profiles(id);

-- =====================================================
-- PASO 5: INSERTAR DATOS DE PRUEBA
-- =====================================================

-- Insertar rol de empresa para royerlove24@gmail.com
INSERT INTO public.user_roles (id, role, chosen_at)
SELECT 
    id,
    'company',
    NOW()
FROM auth.users 
WHERE email = 'royerlove24@gmail.com'
ON CONFLICT (id) DO UPDATE SET 
    role = 'company',
    chosen_at = NOW(),
    updated_at = NOW();

-- Insertar perfil de empresa para royerlove24@gmail.com
INSERT INTO public.company_profiles (id, company_name, sector, location)
SELECT 
    id,
    'Tech Solutions Inc',
    'Tecnología',
    'Bogotá, Colombia'
FROM auth.users 
WHERE email = 'royerlove24@gmail.com'
ON CONFLICT (id) DO UPDATE SET 
    company_name = 'Tech Solutions Inc',
    sector = 'Tecnología',
    location = 'Bogotá, Colombia',
    updated_at = NOW();

-- =====================================================
-- PASO 6: VERIFICAR QUE TODO ESTÁ CORRECTO
-- =====================================================

-- Verificar estructura de user_roles
SELECT 'ESTRUCTURA DE USER_ROLES:' as info;
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'user_roles' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- Verificar estructura de candidate_profiles
SELECT 'ESTRUCTURA DE CANDIDATE_PROFILES:' as info;
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'candidate_profiles' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- Verificar estructura de company_profiles
SELECT 'ESTRUCTURA DE COMPANY_PROFILES:' as info;
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'company_profiles' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- Verificar datos insertados
SELECT 'DATOS INSERTADOS:' as info;
SELECT 
    ur.id,
    u.email,
    ur.role,
    ur.chosen_at,
    cp.company_name,
    cp.sector,
    cp.location
FROM public.user_roles ur
JOIN auth.users u ON u.id = ur.id
LEFT JOIN public.company_profiles cp ON cp.id = ur.id
WHERE u.email = 'royerlove24@gmail.com';

-- =====================================================
-- MENSAJE DE CONFIRMACIÓN
-- =====================================================

SELECT '¡TODAS LAS TABLAS CORREGIDAS EXITOSAMENTE!' as mensaje;
SELECT 'Ahora puedes usar tanto el rol de CANDIDATO como EMPRESA sin errores.' as info;