-- Create table for AI-generated jobs
CREATE TABLE ai_generated_jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  company_name TEXT NOT NULL,
  location TEXT NOT NULL DEFAULT 'Remote',
  work_mode TEXT NOT NULL CHECK (work_mode IN ('remote', 'hybrid', 'onsite')),
  job_type TEXT NOT NULL CHECK (job_type IN ('full_time', 'part_time', 'contract', 'internship')),
  salary_min INTEGER,
  salary_max INTEGER,
  currency TEXT NOT NULL DEFAULT 'USD',
  skills TEXT[] DEFAULT '{}',
  requirements TEXT,
  benefits TEXT,
  ai_confidence_score DOUBLE PRECISION NOT NULL DEFAULT 0.0,
  ai_search_query TEXT NOT NULL,
  generated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX idx_ai_generated_jobs_search_query ON ai_generated_jobs(ai_search_query);
CREATE INDEX idx_ai_generated_jobs_active ON ai_generated_jobs(is_active) WHERE is_active = true;
CREATE INDEX idx_ai_generated_jobs_confidence ON ai_generated_jobs(ai_confidence_score DESC);
CREATE INDEX idx_ai_generated_jobs_generated_at ON ai_generated_jobs(generated_at DESC);

-- Enable RLS
ALTER TABLE ai_generated_jobs ENABLE ROW LEVEL SECURITY;

-- Create policies for anon and authenticated users
CREATE POLICY "Anyone can view active AI generated jobs" ON ai_generated_jobs
  FOR SELECT
  USING (is_active = true);

CREATE POLICY "Authenticated users can view all AI generated jobs" ON ai_generated_jobs
  FOR SELECT
  TO authenticated
  USING (true);

CREATE POLICY "Anyone can create AI generated jobs" ON ai_generated_jobs
  FOR INSERT
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update AI generated jobs" ON ai_generated_jobs
  FOR UPDATE
  TO authenticated
  USING (true);

-- Grant permissions
GRANT SELECT ON ai_generated_jobs TO anon, authenticated;
GRANT INSERT ON ai_generated_jobs TO anon, authenticated;
GRANT UPDATE ON ai_generated_jobs TO authenticated;

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for updated_at
CREATE TRIGGER update_ai_generated_jobs_updated_at
  BEFORE UPDATE ON ai_generated_jobs
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();