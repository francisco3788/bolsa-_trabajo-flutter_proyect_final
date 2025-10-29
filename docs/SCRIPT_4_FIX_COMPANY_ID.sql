-- =====================================================
-- SCRIPT 4: CORREGIR COMPANY_ID EN TRABAJOS
-- =====================================================
-- Este script corrige el problema donde los trabajos tienen 
-- company_id como email en lugar del UUID del usuario

-- Primero, verificamos el estado actual
SELECT 
    id,
    title,
    company_id,
    company_name
FROM jobs 
WHERE company_id = 'royerlove24@gmail.com';

-- Obtenemos el UUID del usuario con el email royerlove24@gmail.com
SELECT 
    id as user_uuid,
    email
FROM auth.users 
WHERE email = 'royerlove24@gmail.com';

-- Actualizamos los trabajos para usar el UUID correcto
UPDATE jobs 
SET company_id = (
    SELECT id 
    FROM auth.users 
    WHERE email = 'royerlove24@gmail.com'
)
WHERE company_id = 'royerlove24@gmail.com';

-- Verificamos que la actualización fue exitosa
SELECT 
    id,
    title,
    company_id,
    company_name,
    status
FROM jobs 
WHERE company_id = (
    SELECT id 
    FROM auth.users 
    WHERE email = 'royerlove24@gmail.com'
);

-- Verificamos que los trabajos aparezcan en la vista jobs_with_stats
SELECT 
    id,
    title,
    company_id,
    company_name,
    status,
    total_applications,
    new_applications
FROM jobs_with_stats 
WHERE company_id = (
    SELECT id 
    FROM auth.users 
    WHERE email = 'royerlove24@gmail.com'
);