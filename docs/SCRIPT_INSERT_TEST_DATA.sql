-- =====================================================
-- SCRIPT DE DATOS DE PRUEBA CON UUIDs CORRECTOS
-- =====================================================
-- Este script inserta datos de prueba usando los UUIDs 
-- reales de los usuarios autenticados

-- =====================================================
-- PASO 1: VERIFICAR USUARIO EXISTENTE
-- =====================================================

-- Verificar que el usuario royerlove24@gmail.com existe
SELECT 
    id as user_uuid,
    email,
    created_at
FROM auth.users 
WHERE email = 'royerlove24@gmail.com';

-- =====================================================
-- PASO 2: CONFIGURAR ROL Y PERFIL DE EMPRESA
-- =====================================================

-- Insertar rol de empresa para el usuario
INSERT INTO public.user_roles (user_id, role)
SELECT 
    id,
    'company'
FROM auth.users 
WHERE email = 'royerlove24@gmail.com'
ON CONFLICT (user_id) DO UPDATE SET role = 'company';

-- Insertar perfil de empresa
INSERT INTO public.company_profiles (user_id, company_name, sector, location)
SELECT 
    id,
    'TechCorp Solutions',
    'Tecnología',
    'Madrid, España'
FROM auth.users 
WHERE email = 'royerlove24@gmail.com'
ON CONFLICT (user_id) DO UPDATE SET 
    company_name = 'TechCorp Solutions',
    sector = 'Tecnología',
    location = 'Madrid, España',
    updated_at = NOW();

-- =====================================================
-- PASO 3: INSERTAR TRABAJOS CON UUID CORRECTO
-- =====================================================

-- Trabajo 1: Desarrollador Frontend Senior
INSERT INTO public.jobs (
    company_id,
    title,
    description,
    company_name,
    location,
    work_mode,
    job_type,
    salary_min,
    salary_max,
    currency,
    skills,
    requirements,
    benefits,
    status
)
SELECT 
    id, -- UUID del usuario
    'Desarrollador Frontend Senior',
    'Buscamos un desarrollador frontend senior con experiencia en React, Vue.js y Angular. Trabajarás en proyectos innovadores con las últimas tecnologías.',
    'TechCorp Solutions',
    'Madrid, España',
    'hybrid',
    'full_time',
    45000,
    65000,
    'EUR',
    ARRAY['React', 'Vue.js', 'Angular', 'TypeScript', 'JavaScript', 'CSS3', 'HTML5'],
    'Mínimo 5 años de experiencia en desarrollo frontend. Conocimientos sólidos en frameworks modernos de JavaScript. Experiencia con herramientas de build como Webpack, Vite. Conocimientos en testing (Jest, Cypress).',
    'Seguro médico privado, 25 días de vacaciones, formación continua, trabajo híbrido, horario flexible.',
    'active'
FROM auth.users 
WHERE email = 'royerlove24@gmail.com';

-- Trabajo 2: Analista de Datos
INSERT INTO public.jobs (
    company_id,
    title,
    description,
    company_name,
    location,
    work_mode,
    job_type,
    salary_min,
    salary_max,
    currency,
    skills,
    requirements,
    benefits,
    status
)
SELECT 
    id, -- UUID del usuario
    'Analista de Datos',
    'Únete a nuestro equipo de data science. Analizarás grandes volúmenes de datos para generar insights que impulsen decisiones estratégicas.',
    'TechCorp Solutions',
    'Barcelona, España',
    'remote',
    'full_time',
    40000,
    55000,
    'EUR',
    ARRAY['Python', 'SQL', 'Tableau', 'Power BI', 'Excel', 'R', 'Machine Learning'],
    'Licenciatura en Estadística, Matemáticas, Ingeniería o campo relacionado. Experiencia con Python y SQL. Conocimientos en visualización de datos. Capacidad analítica y atención al detalle.',
    'Trabajo 100% remoto, equipamiento completo, seguro médico, plan de pensiones, días de salud mental.',
    'active'
FROM auth.users 
WHERE email = 'royerlove24@gmail.com';

-- Trabajo 3: Diseñador UX/UI
INSERT INTO public.jobs (
    company_id,
    title,
    description,
    company_name,
    location,
    work_mode,
    job_type,
    salary_min,
    salary_max,
    currency,
    skills,
    requirements,
    benefits,
    status
)
SELECT 
    id, -- UUID del usuario
    'Diseñador UX/UI',
    'Buscamos un diseñador creativo para mejorar la experiencia de usuario de nuestros productos digitales. Trabajarás en estrecha colaboración con el equipo de desarrollo.',
    'TechCorp Solutions',
    'Valencia, España',
    'onsite',
    'full_time',
    35000,
    50000,
    'EUR',
    ARRAY['Figma', 'Adobe XD', 'Sketch', 'Photoshop', 'Illustrator', 'Prototyping', 'User Research'],
    'Experiencia mínima de 3 años en diseño UX/UI. Portfolio sólido con casos de estudio. Conocimientos en research y testing de usuarios. Capacidad para trabajar en equipo multidisciplinar.',
    'Oficina moderna en el centro de Valencia, café y snacks gratis, team building mensual, formación en diseño.',
    'pending'
FROM auth.users 
WHERE email = 'royerlove24@gmail.com';

-- =====================================================
-- PASO 4: CREAR ALGUNOS CANDIDATOS DE PRUEBA
-- =====================================================

-- Nota: Estos candidatos son ficticios para testing
-- En producción, los usuarios se registrarían normalmente

-- Insertar un candidato ficticio (solo para testing de postulaciones)
-- Esto simula que hay candidatos que se han postulado

-- =====================================================
-- PASO 5: VERIFICAR DATOS INSERTADOS
-- =====================================================

-- Verificar trabajos creados
SELECT 
    id,
    title,
    company_id,
    company_name,
    location,
    work_mode,
    status,
    created_at
FROM public.jobs 
WHERE company_id = (
    SELECT id FROM auth.users WHERE email = 'royerlove24@gmail.com'
)
ORDER BY created_at DESC;

-- Verificar que aparecen en la vista jobs_with_stats
SELECT 
    id,
    title,
    company_name,
    status,
    total_applications,
    new_applications
FROM public.jobs_with_stats 
WHERE company_id = (
    SELECT id FROM auth.users WHERE email = 'royerlove24@gmail.com'
)
ORDER BY created_at DESC;

-- Verificar perfil de empresa
SELECT 
    user_id,
    company_name,
    sector,
    location
FROM public.company_profiles 
WHERE user_id = (
    SELECT id FROM auth.users WHERE email = 'royerlove24@gmail.com'
);

-- Verificar rol de usuario
SELECT 
    user_id,
    role
FROM public.user_roles 
WHERE user_id = (
    SELECT id FROM auth.users WHERE email = 'royerlove24@gmail.com'
);

-- =====================================================
-- MENSAJE DE CONFIRMACIÓN
-- =====================================================

SELECT 'Datos de prueba insertados exitosamente!' as mensaje;