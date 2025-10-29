-- =====================================================
-- SCRIPT PARA CORREGIR TABLA USER_ROLES
-- =====================================================
-- Este script elimina y recrea la tabla user_roles 
-- con la columna 'chosen_at' que falta

-- =====================================================
-- PASO 1: ELIMINAR TABLA EXISTENTE
-- =====================================================

-- Eliminar políticas RLS de user_roles si existen
DROP POLICY IF EXISTS "Users can view their own role" ON public.user_roles;
DROP POLICY IF EXISTS "Users can insert their own role" ON public.user_roles;
DROP POLICY IF EXISTS "Users can update their own role" ON public.user_roles;

-- Eliminar la tabla user_roles
DROP TABLE IF EXISTS public.user_roles CASCADE;

-- =====================================================
-- PASO 2: CREAR TABLA CON ESTRUCTURA CORRECTA
-- =====================================================

CREATE TABLE public.user_roles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('candidate', 'company')),
    chosen_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(), -- ← Esta columna faltaba!
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- PASO 3: CONFIGURAR RLS (ROW LEVEL SECURITY)
-- =====================================================

-- Habilitar RLS
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;

-- Política para ver el propio rol
CREATE POLICY "Users can view their own role" ON public.user_roles
    FOR SELECT USING (auth.uid() = id);

-- Política para insertar el propio rol
CREATE POLICY "Users can insert their own role" ON public.user_roles
    FOR INSERT WITH CHECK (auth.uid() = id);

-- Política para actualizar el propio rol
CREATE POLICY "Users can update their own role" ON public.user_roles
    FOR UPDATE USING (auth.uid() = id);

-- =====================================================
-- PASO 4: CREAR ÍNDICES PARA OPTIMIZACIÓN
-- =====================================================

CREATE INDEX idx_user_roles_id ON public.user_roles(id);
CREATE INDEX idx_user_roles_role ON public.user_roles(role);

-- =====================================================
-- PASO 5: INSERTAR ROL PARA EL USUARIO ACTUAL
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

-- =====================================================
-- PASO 6: VERIFICAR QUE TODO ESTÁ CORRECTO
-- =====================================================

-- Verificar estructura de la tabla
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'user_roles' 
AND table_schema = 'public'
ORDER BY ordinal_position;

-- Verificar que el rol se insertó correctamente
SELECT 
    ur.id,
    u.email,
    ur.role,
    ur.chosen_at,
    ur.created_at
FROM public.user_roles ur
JOIN auth.users u ON u.id = ur.id
WHERE u.email = 'royerlove24@gmail.com';

-- =====================================================
-- MENSAJE DE CONFIRMACIÓN
-- =====================================================

SELECT 'Tabla user_roles corregida exitosamente con la columna chosen_at!' as mensaje;