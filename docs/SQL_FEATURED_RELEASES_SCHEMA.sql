-- ============================================================================
-- FEATURED RELEASES TABLE SETUP
-- Run this SQL in your Supabase SQL Editor
-- ============================================================================

-- Step 1: Create the featured_releases table
CREATE TABLE featured_releases (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  media_content_id UUID NOT NULL REFERENCES media_page_content(id) ON DELETE CASCADE,
  display_order INTEGER NOT NULL DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  -- Admin can override these fields if needed
  admin_edited_title TEXT,
  admin_edited_creator TEXT,
  admin_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
  featured_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  CONSTRAINT unique_featured_content UNIQUE(media_content_id)
);

-- Step 2: Create index for faster queries
CREATE INDEX idx_featured_releases_active_order 
ON featured_releases(is_active, display_order);

-- Step 3: Enable RLS (Row Level Security)
ALTER TABLE featured_releases ENABLE ROW LEVEL SECURITY;

-- Step 4: Create Policies

-- Policy: Anyone can read active featured releases
CREATE POLICY "Featured releases are readable by all"
  ON featured_releases FOR SELECT
  USING (is_active = true);

-- Step 5: Admin-only insert policy
-- NOTE: Replace 'admin@flourishtalents.com' with your actual admin email
CREATE POLICY "Only admins can insert featured releases"
  ON featured_releases FOR INSERT
  WITH CHECK (
    auth.jwt() ->> 'email' = 'admin@flourishtalents.com'
    OR auth.jwt() ->> 'email' = 'your-second-admin@example.com'
  );

-- Step 6: Admin-only update policy
CREATE POLICY "Only admins can update featured releases"
  ON featured_releases FOR UPDATE
  USING (auth.jwt() ->> 'email' = 'admin@flourishtalents.com'
    OR auth.jwt() ->> 'email' = 'your-second-admin@example.com')
  WITH CHECK (auth.jwt() ->> 'email' = 'admin@flourishtalents.com'
    OR auth.jwt() ->> 'email' = 'your-second-admin@example.com');

-- Step 7: Admin-only delete policy
CREATE POLICY "Only admins can delete featured releases"
  ON featured_releases FOR DELETE
  USING (auth.jwt() ->> 'email' = 'admin@flourishtalents.com'
    OR auth.jwt() ->> 'email' = 'your-second-admin@example.com');

-- ============================================================================
-- INSTRUCTIONS
-- ============================================================================
-- 
-- 1. Copy the SQL above and paste it into your Supabase SQL Editor
-- 2. Update the email addresses:
--    - Replace 'admin@flourishtalents.com' with your admin email
--    - Add more admin emails by adding: OR auth.jwt() ->> 'email' = 'another-admin@example.com'
-- 3. Click "Run" to execute
-- 4. The featured_releases table is now ready to use
--
-- ============================================================================
-- TESTING THE SETUP
-- ============================================================================
--
-- To test if the table was created successfully:
-- SELECT * FROM featured_releases;
--
-- To verify RLS is enabled:
-- SELECT tablename FROM pg_tables WHERE schemaname = 'public' AND tablename = 'featured_releases';
--
-- ============================================================================
