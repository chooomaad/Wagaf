-- ============================================================
-- SALAM APP - Migration 003: Fix RLS Policies & Triggers
-- Run this in the Supabase SQL editor AFTER migrations 001 & 002
-- ============================================================

-- ============================================================
-- 1. FIX: handle_new_user trigger
--    Now reads phone/city from signup metadata so Flutter
--    doesn't need a separate client-side INSERT (which RLS blocks).
-- ============================================================

CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, phone, city)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(
      NEW.raw_user_meta_data->>'full_name',
      split_part(NEW.email, '@', 1)
    ),
    NEW.raw_user_meta_data->>'phone',
    NEW.raw_user_meta_data->>'city'
  )
  ON CONFLICT (id) DO UPDATE SET
    email      = EXCLUDED.email,
    full_name  = COALESCE(EXCLUDED.full_name, public.profiles.full_name),
    phone      = COALESCE(EXCLUDED.phone,     public.profiles.phone),
    city       = COALESCE(EXCLUDED.city,      public.profiles.city);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- 2. FIX: handle_order_status_change trigger
--    Must be SECURITY DEFINER so it can INSERT tracking_events
--    even when RLS restricts the calling user.
-- ============================================================

CREATE OR REPLACE FUNCTION handle_order_status_change()
RETURNS TRIGGER AS $$
DECLARE
  status_titles JSONB := '{
    "pending":             "Commande reçue",
    "payment_validated":   "Paiement validé",
    "purchased":           "Produit acheté",
    "in_transit":          "En transit",
    "arrived_mauritania":  "Arrivé en Mauritanie",
    "delivered":           "Livré",
    "cancelled":           "Commande annulée",
    "refunded":            "Remboursé"
  }';
BEGIN
  IF NEW.status <> OLD.status THEN
    INSERT INTO public.tracking_events (order_id, status, title)
    VALUES (
      NEW.id,
      NEW.status,
      COALESCE(status_titles ->> NEW.status::TEXT, NEW.status::TEXT)
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- 3. FIX: update_profile_totals trigger - add SECURITY DEFINER
-- ============================================================

CREATE OR REPLACE FUNCTION update_profile_totals()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'delivered' AND OLD.status <> 'delivered' THEN
    UPDATE public.profiles
    SET
      total_orders = total_orders + 1,
      total_spent  = total_spent + NEW.total_mru
    WHERE id = NEW.user_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- 4. FIX: is_admin() and is_super_admin()
--    Use SET search_path and cache via stable to avoid repeated
--    queries. Add explicit schema to prevent search_path hijack.
-- ============================================================

CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1
    FROM   public.profiles
    WHERE  id     = auth.uid()
    AND    role   IN ('admin', 'super_admin')
    AND    status = 'active'
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE
   SET search_path = public;

CREATE OR REPLACE FUNCTION is_super_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1
    FROM   public.profiles
    WHERE  id     = auth.uid()
    AND    role   = 'super_admin'
    AND    status = 'active'
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE
   SET search_path = public;

-- ============================================================
-- 5. FIX: PROFILES POLICIES
--    Drop all existing and recreate cleanly.
-- ============================================================

-- Drop old policies
DROP POLICY IF EXISTS "profiles_select_own"    ON public.profiles;
DROP POLICY IF EXISTS "profiles_select_admin"  ON public.profiles;
DROP POLICY IF EXISTS "profiles_update_own"    ON public.profiles;
DROP POLICY IF EXISTS "profiles_update_admin"  ON public.profiles;
DROP POLICY IF EXISTS "profiles_insert_own"    ON public.profiles;

-- SELECT: own profile
CREATE POLICY "profiles_select_own" ON public.profiles
  FOR SELECT
  USING (auth.uid() = id);

-- SELECT: admins can read all
CREATE POLICY "profiles_select_admin" ON public.profiles
  FOR SELECT
  USING (is_admin());

-- INSERT: users can insert their own profile row
-- (safety net — the DB trigger handles this normally)
CREATE POLICY "profiles_insert_own" ON public.profiles
  FOR INSERT
  WITH CHECK (auth.uid() = id);

-- UPDATE: users update own profile — simple check, no recursive subquery
-- Role/status escalation is prevented by the trigger below
CREATE POLICY "profiles_update_own" ON public.profiles
  FOR UPDATE
  USING  (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- UPDATE: admins can update any profile
CREATE POLICY "profiles_update_admin" ON public.profiles
  FOR UPDATE
  USING (is_admin());

-- ============================================================
-- 6. ADD: Trigger to prevent non-admin role/status escalation
-- ============================================================

CREATE OR REPLACE FUNCTION prevent_role_escalation()
RETURNS TRIGGER AS $$
BEGIN
  -- Only non-admin users are restricted
  IF NOT is_admin() THEN
    IF NEW.role <> OLD.role THEN
      RAISE EXCEPTION 'Modification du rôle non autorisée'
        USING ERRCODE = '42501';
    END IF;
    IF NEW.status <> OLD.status THEN
      RAISE EXCEPTION 'Modification du statut non autorisée'
        USING ERRCODE = '42501';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER
   SET search_path = public;

DROP TRIGGER IF EXISTS trg_prevent_role_escalation ON public.profiles;
CREATE TRIGGER trg_prevent_role_escalation
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION prevent_role_escalation();

-- ============================================================
-- 7. FIX: PRODUCTS POLICIES
--    Replace deprecated auth.role() with auth.uid() IS NOT NULL
-- ============================================================

DROP POLICY IF EXISTS "products_select_all" ON public.products;
CREATE POLICY "products_select_all" ON public.products
  FOR SELECT
  USING (auth.uid() IS NOT NULL);

-- ============================================================
-- 8. FIX: SETTINGS POLICIES
--    Replace deprecated auth.role()
-- ============================================================

DROP POLICY IF EXISTS "settings_select_all" ON public.settings;
CREATE POLICY "settings_select_all" ON public.settings
  FOR SELECT
  USING (auth.uid() IS NOT NULL);

-- ============================================================
-- 9. FIX: ORDERS — add DELETE policy for admins
-- ============================================================

DROP POLICY IF EXISTS "orders_delete_admin" ON public.orders;
CREATE POLICY "orders_delete_admin" ON public.orders
  FOR DELETE USING (is_admin());

-- ============================================================
-- 10. FIX: PAYMENTS — add DELETE policy for admins
-- ============================================================

DROP POLICY IF EXISTS "payments_delete_admin" ON public.payments;
CREATE POLICY "payments_delete_admin" ON public.payments
  FOR DELETE USING (is_admin());

-- ============================================================
-- 11. FIX: TRACKING — add update policy for admins
-- ============================================================

DROP POLICY IF EXISTS "tracking_update_admin" ON public.tracking_events;
CREATE POLICY "tracking_update_admin" ON public.tracking_events
  FOR UPDATE USING (is_admin());

DROP POLICY IF EXISTS "tracking_delete_admin" ON public.tracking_events;
CREATE POLICY "tracking_delete_admin" ON public.tracking_events
  FOR DELETE USING (is_admin());

-- ============================================================
-- 12. GRANTS — ensure correct schema-level permissions
-- ============================================================

GRANT USAGE ON SCHEMA public TO anon, authenticated;

-- profiles
GRANT SELECT, INSERT, UPDATE             ON public.profiles          TO authenticated;
-- orders
GRANT SELECT, INSERT, UPDATE             ON public.orders            TO authenticated;
-- payments
GRANT SELECT, INSERT                     ON public.payments          TO authenticated;
-- tracking
GRANT SELECT                             ON public.tracking_events   TO authenticated;
-- notifications
GRANT SELECT, INSERT, UPDATE             ON public.notifications     TO authenticated;
-- settings (read-only for users)
GRANT SELECT                             ON public.settings          TO authenticated;
-- products
GRANT SELECT                             ON public.products          TO authenticated;
-- admin_logs (admin only via RLS)
GRANT SELECT, INSERT                     ON public.admin_logs        TO authenticated;

-- Sequence for order numbers
GRANT USAGE, SELECT ON SEQUENCE order_number_seq TO authenticated;
