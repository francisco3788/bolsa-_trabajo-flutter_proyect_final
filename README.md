# bolsa_de_trabajo

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

---

## AI Overview (Spanish)

La aplicación integra un módulo de IA para acelerar la creación y gestión de empleos. La IA se usa en dos frentes:
- Generación de vacantes a partir de una consulta (candidato)
- Sugerencias de estado y análisis de postulaciones (empresa)

### Cómo usar la IA (Candidatos)
- Abre “AI‑Powered Job Search”
- Escribe un rol o palabras clave (ej. "Flutter Developer", "Remote, Python")
- Pulsa “Generate” para ver 10 empleos realistas con descripción, skills y filtros
- Usa los filtros (Location, Work Mode, Job Type) para refinar
- Pulsa “Apply Now” para postular, añade cover letter y envía

### Cómo usar la IA (Empresas)
- Abre “Company Dashboard”
- Filtra por estado (All/Pending/Under Review/Accepted/Rejected) y usa la búsqueda
- En una postulación, pulsa acciones: “Mark Under Review”, “Accept”, “Reject” con notas
- Usa “AI Batch Suggest” para recomendaciones masivas por calidad (heurística)
- Revisa el resumen IA (quality) para priorizar revisiones

### Prompt maestro (copiar y pegar)


You are an AI job generator for a job board.
Given a search query, generate up to 10 realistic job postings with:
- title, company_name, location, work_mode (remote|hybrid|onsite)
- job_type (full_time|part_time|contract|internship)
- description (2–3 paragraphs), requirements (bullet points), benefits (optional)
- skills (5–8 relevant skills), salary_min/max (optional), experience_level
Constraints:
- Be concise, specific, and plausible for the region implied in the query
- Avoid duplicate titles or repeated descriptions
- Include varied work modes and job types when reasonable
Output JSON array with objects matching the above fields.


Ejemplos de consulta:
- "Flutter Developer, remote, Latin America"
- "Data Analyst, Python, junior, Bogotá"
- "Backend Node.js, hybrid, full-time"

### Prompt de sugerencias de estado (empresas)


You are an AI recruitment assistant. Analyze a single job application and suggest a status:
- Inputs: job_title, job_description, requirements, candidate_name, email, cover_letter, additional_data (linkedin, experience_years, etc.)
- Output JSON:
  {
    "suggested_status": "pending|underReview|accepted|rejected",
    "confidence_score": 0.0–1.0,
    "reasoning": "brief explanation",
    "key_strengths": ["..."],
    "key_concerns": ["..."],
    "recommended_next_steps": "..."
  }
Be objective and professional.


### Notas técnicas
- El tema global usa colorSchemeSeed: #3A5A92 para una paleta única
- Supabase requiere la tabla public.job_applications con columnas: id, job_id, company_id, candidate_id, candidate_name, candidate_email, candidate_phone, resume_url, cover_letter, status, source, applied_at, status_updated_at, notes, metadata (jsonb)
- Estados válidos: pending, underReview, accepted, rejected, cancelled
