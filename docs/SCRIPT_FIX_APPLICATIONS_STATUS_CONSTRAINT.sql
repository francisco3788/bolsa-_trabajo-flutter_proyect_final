-- Normalize allowed values for applications.status to app’s canonical set
-- Maps old values to new ones, then replaces the check constraint.

BEGIN;

-- 0) Map legacy statuses to canonical ones (safe update)
UPDATE public.applications
SET status = CASE
  WHEN status = 'reviewing' THEN 'seen'
  WHEN status = 'accepted' THEN 'hired'
  WHEN status = 'new' THEN 'submitted'
  WHEN status = 'contratado' THEN 'hired'
  WHEN status = 'rechazado' THEN 'rejected'
  WHEN status = 'entrevista' THEN 'interview'
  WHEN status = 'visto' THEN 'seen'
  ELSE status
END;

-- 1) Drop existing status check constraint if present
DO $$ BEGIN
  IF EXISTS (
    SELECT 1 FROM pg_constraint 
    WHERE conname = 'applications_status_check'
  ) THEN
    ALTER TABLE public.applications DROP CONSTRAINT applications_status_check;
  END IF;
END $$;

-- 2) Add canonical status check constraint
ALTER TABLE public.applications
  ADD CONSTRAINT applications_status_check
  CHECK (status IN ('submitted','seen','interview','rejected','hired'));

COMMIT;

-- After this, only these values are valid:
-- submitted, seen, interview, rejected, hired