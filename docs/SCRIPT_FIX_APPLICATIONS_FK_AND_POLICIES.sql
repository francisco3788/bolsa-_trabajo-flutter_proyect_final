-- Fix applications → candidate_profiles foreign key and add safe RLS policies
-- This script normalizes candidate_profiles.id and ensures PostgREST can infer
-- the relationship for embedded selects like:
--   select: applications(*, candidate_profiles(name))

BEGIN;

-- 1) Normalize candidate_profiles primary key to `id` and reference auth.users(id)
DO $$ BEGIN
  -- If legacy column `user_id` exists, rename it to `id`
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public' AND table_name = 'candidate_profiles' AND column_name = 'user_id'
  ) THEN
    ALTER TABLE public.candidate_profiles RENAME COLUMN user_id TO id;
  END IF;
END $$;

-- Ensure `id` is NOT NULL
ALTER TABLE public.candidate_profiles
  ALTER COLUMN id SET NOT NULL;

-- Ensure primary key on `id`
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'candidate_profiles_pkey'
  ) THEN
    ALTER TABLE public.candidate_profiles
      ADD CONSTRAINT candidate_profiles_pkey PRIMARY KEY (id);
  END IF;
END $$;

-- Ensure foreign key from candidate_profiles.id → auth.users(id)
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'candidate_profiles_id_fkey'
  ) THEN
    ALTER TABLE public.candidate_profiles
      ADD CONSTRAINT candidate_profiles_id_fkey
        FOREIGN KEY (id) REFERENCES auth.users(id)
        ON UPDATE CASCADE ON DELETE CASCADE;
  END IF;
END $$;

-- 2) Re-point applications.candidate_id to candidate_profiles(id)
DO $$ BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'applications_candidate_id_fkey'
  ) THEN
    ALTER TABLE public.applications DROP CONSTRAINT applications_candidate_id_fkey;
  END IF;
END $$;

DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'applications_candidate_id_candidate_profiles_fkey'
  ) THEN
    ALTER TABLE public.applications
      ADD CONSTRAINT applications_candidate_id_candidate_profiles_fkey
        FOREIGN KEY (candidate_id) REFERENCES public.candidate_profiles(id)
        ON UPDATE CASCADE ON DELETE RESTRICT;
  END IF;
END $$;

-- Helpful indexes
CREATE INDEX IF NOT EXISTS idx_applications_candidate_id ON public.applications(candidate_id);
CREATE INDEX IF NOT EXISTS idx_candidate_profiles_id ON public.candidate_profiles(id);

-- 3) RLS policies allowing safe reads
ALTER TABLE public.candidate_profiles ENABLE ROW LEVEL SECURITY;

-- Candidates can read their own profile
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='candidate_profiles' AND policyname='candidate_read_own_profile'
  ) THEN
    CREATE POLICY candidate_read_own_profile
      ON public.candidate_profiles FOR SELECT
      USING (id = auth.uid());
  END IF;
END $$;

-- Companies can read applicants for their own jobs
DO $$ BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='candidate_profiles' AND policyname='company_read_applicants_for_own_jobs'
  ) THEN
    CREATE POLICY company_read_applicants_for_own_jobs
      ON public.candidate_profiles FOR SELECT
      USING (
        EXISTS (
          SELECT 1
          FROM public.applications a
          JOIN public.jobs j ON j.id = a.job_id
          WHERE a.candidate_id = candidate_profiles.id
            AND j.company_id = auth.uid()
        )
      );
  END IF;
END $$;

COMMIT;

-- After running this, you can safely use embedded selects:
-- select: applications(*, candidate_profiles(name))
-- and PostgREST will infer the relationship from the new foreign key.