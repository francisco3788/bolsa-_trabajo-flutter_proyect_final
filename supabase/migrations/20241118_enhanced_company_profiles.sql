-- Enhanced company profiles table with additional fields
ALTER TABLE company_profiles
ADD COLUMN IF NOT EXISTS logo_url TEXT,
ADD COLUMN IF NOT EXISTS website TEXT,
ADD COLUMN IF NOT EXISTS size TEXT CHECK (size IN ('startup', 'small', 'medium', 'large', 'enterprise')),
ADD COLUMN IF NOT EXISTS founded_year INTEGER CHECK (founded_year >= 1800 AND founded_year <= EXTRACT(YEAR FROM CURRENT_DATE)),
ADD COLUMN IF NOT EXISTS description TEXT,
ADD COLUMN IF NOT EXISTS culture TEXT,
ADD COLUMN IF NOT EXISTS contact_person TEXT,
ADD COLUMN IF NOT EXISTS contact_email TEXT,
ADD COLUMN IF NOT EXISTS contact_phone TEXT,
ADD COLUMN IF NOT EXISTS address TEXT,
ADD COLUMN IF NOT EXISTS benefits TEXT[],
ADD COLUMN IF NOT EXISTS work_schedule TEXT,
ADD COLUMN IF NOT EXISTS remote_policy TEXT CHECK (remote_policy IN ('fullyRemote', 'hybrid', 'officeOnly', 'flexible')),
ADD COLUMN IF NOT EXISTS linkedin_url TEXT,
ADD COLUMN IF NOT EXISTS twitter_handle TEXT,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP;

-- Create storage bucket for company logos
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES ('company_logos', 'company_logos', true, 5242880, ARRAY['image/jpeg', 'image/png', 'image/webp'])
ON CONFLICT (id) DO NOTHING;

-- Enable Row Level Security
ALTER TABLE company_profiles ENABLE ROW LEVEL SECURITY;

-- Create policies for company_profiles table
CREATE POLICY "Users can view own company profile" ON company_profiles
    FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can insert own company profile" ON company_profiles
    FOR INSERT WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own company profile" ON company_profiles
    FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can delete own company profile" ON company_profiles
    FOR DELETE USING (auth.uid() = id);

-- Create policy for storage bucket
CREATE POLICY "Users can upload company logos" ON storage.objects
    FOR INSERT WITH CHECK (
        bucket_id = 'company_logos' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can update company logos" ON storage.objects
    FOR UPDATE USING (
        bucket_id = 'company_logos' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Users can delete company logos" ON storage.objects
    FOR DELETE USING (
        bucket_id = 'company_logos' AND
        auth.uid()::text = (storage.foldername(name))[1]
    );

CREATE POLICY "Public can view company logos" ON storage.objects
    FOR SELECT USING (bucket_id = 'company_logos');

-- Grant permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON company_profiles TO authenticated;
GRANT SELECT ON company_profiles TO anon;
GRANT ALL ON storage.objects TO authenticated;
GRANT SELECT ON storage.objects TO anon;