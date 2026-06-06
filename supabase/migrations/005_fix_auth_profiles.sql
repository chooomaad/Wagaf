-- ============================================================
-- SALAM / SH7ANLY APP — Migration 005: Fix Auth Profiles
-- Run in Supabase SQL editor AFTER migration 004
--
-- Purpose:
--   1. Backfill profiles for existing auth.users who have no profile row
--      (accounts created before the trigger, or where trigger failed)
--   2. Re-create handle_new_user trigger with extra robustness
-- ============================================================

-- ============================================================
-- 1. BACKFILL missing profiles for all existing auth users
-- ============================================================
INSERT INTO public.profiles (id, email, full_name, phone, city, address)
SELECT
  au.id,
  COALESCE(au.email, ''),
  COALESCE(
    NULLIF(TRIM(au.raw_user_meta_data->>'full_name'), ''),
    split_part(COALESCE(au.email, 'utilisateur'), '@', 1)
  ),
  NULLIF(TRIM(au.raw_user_meta_data->>'phone'),   ''),
  NULLIF(TRIM(au.raw_user_meta_data->>'city'),    ''),
  NULLIF(TRIM(au.raw_user_meta_data->>'address'), '')
FROM auth.users au
LEFT JOIN public.profiles p ON p.id = au.id
WHERE p.id IS NULL
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- 2. REPLACE handle_new_user with a bulletproof version
-- ============================================================
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, phone, city, address)
  VALUES (
    NEW.id,
    COALESCE(NEW.email, ''),
    COALESCE(
      NULLIF(TRIM(NEW.raw_user_meta_data->>'full_name'), ''),
      split_part(COALESCE(NEW.email, 'utilisateur'), '@', 1)
    ),
    NULLIF(TRIM(NEW.raw_user_meta_data->>'phone'),   ''),
    NULLIF(TRIM(NEW.raw_user_meta_data->>'city'),    ''),
    NULLIF(TRIM(NEW.raw_user_meta_data->>'address'), '')
  )
  ON CONFLICT (id) DO UPDATE SET
    email     = EXCLUDED.email,
    full_name = COALESCE(EXCLUDED.full_name, public.profiles.full_name),
    phone     = COALESCE(EXCLUDED.phone,     public.profiles.phone),
    city      = COALESCE(EXCLUDED.city,      public.profiles.city),
    address   = COALESCE(EXCLUDED.address,   public.profiles.address);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- ============================================================
-- 3. GRANT INSERT on profiles to authenticated (needed for
--    client-side upsert fallback when trigger fails)
-- ============================================================
GRANT INSERT ON public.profiles TO authenticated;
