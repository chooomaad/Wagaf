-- ============================================================
-- SALAM / SH7ANLY APP — Migration 004: Complete Production Schema
-- Run in Supabase SQL editor AFTER migrations 001, 002, 003
-- ============================================================

-- ============================================================
-- 1. ADD address column to profiles (if not exists)
-- ============================================================
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema = 'public'
      AND table_name   = 'profiles'
      AND column_name  = 'address'
  ) THEN
    ALTER TABLE public.profiles ADD COLUMN address TEXT;
  END IF;
END $$;

-- ============================================================
-- 2. FIX handle_new_user — include address from metadata
-- ============================================================
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name, phone, city, address)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(
      NEW.raw_user_meta_data->>'full_name',
      split_part(NEW.email, '@', 1)
    ),
    NEW.raw_user_meta_data->>'phone',
    NEW.raw_user_meta_data->>'city',
    NEW.raw_user_meta_data->>'address'
  )
  ON CONFLICT (id) DO UPDATE SET
    email      = EXCLUDED.email,
    full_name  = COALESCE(EXCLUDED.full_name,  public.profiles.full_name),
    phone      = COALESCE(EXCLUDED.phone,      public.profiles.phone),
    city       = COALESCE(EXCLUDED.city,       public.profiles.city),
    address    = COALESCE(EXCLUDED.address,    public.profiles.address);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Ensure trigger exists (idempotent)
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- ============================================================
-- 3. ORDER NUMBER generation
-- ============================================================
CREATE SEQUENCE IF NOT EXISTS order_number_seq START 1000 INCREMENT 1;

CREATE OR REPLACE FUNCTION generate_order_number()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.order_number IS NULL OR NEW.order_number = '' THEN
    NEW.order_number := 'SH-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' ||
                        LPAD(nextval('order_number_seq')::TEXT, 4, '0');
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_generate_order_number ON public.orders;
CREATE TRIGGER trg_generate_order_number
  BEFORE INSERT ON public.orders
  FOR EACH ROW EXECUTE FUNCTION generate_order_number();

-- ============================================================
-- 4. handle_order_status_change — create tracking event
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
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS trg_order_status_change ON public.orders;
CREATE TRIGGER trg_order_status_change
  AFTER UPDATE OF status ON public.orders
  FOR EACH ROW EXECUTE FUNCTION handle_order_status_change();

-- Also insert tracking event on first INSERT (pending)
CREATE OR REPLACE FUNCTION handle_order_insert()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.tracking_events (order_id, status, title)
  VALUES (NEW.id, 'pending', 'Commande reçue');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS trg_order_insert ON public.orders;
CREATE TRIGGER trg_order_insert
  AFTER INSERT ON public.orders
  FOR EACH ROW EXECUTE FUNCTION handle_order_insert();

-- ============================================================
-- 5. update_profile_totals — increment on delivery
-- ============================================================
CREATE OR REPLACE FUNCTION update_profile_totals()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'delivered' AND (OLD.status IS NULL OR OLD.status <> 'delivered') THEN
    UPDATE public.profiles
    SET
      total_orders = total_orders + 1,
      total_spent  = total_spent + NEW.total_mru
    WHERE id = NEW.user_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS trg_update_profile_totals ON public.orders;
CREATE TRIGGER trg_update_profile_totals
  AFTER UPDATE OF status ON public.orders
  FOR EACH ROW EXECUTE FUNCTION update_profile_totals();

-- ============================================================
-- 6. Helper functions
-- ============================================================
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role IN ('admin', 'super_admin') AND status = 'active'
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE SET search_path = public;

CREATE OR REPLACE FUNCTION is_super_admin()
RETURNS BOOLEAN AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid() AND role = 'super_admin' AND status = 'active'
  );
$$ LANGUAGE sql SECURITY DEFINER STABLE SET search_path = public;

-- ============================================================
-- 7. PROFILES — full RLS policy set
-- ============================================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "profiles_select_own"   ON public.profiles;
DROP POLICY IF EXISTS "profiles_select_admin" ON public.profiles;
DROP POLICY IF EXISTS "profiles_insert_own"   ON public.profiles;
DROP POLICY IF EXISTS "profiles_update_own"   ON public.profiles;
DROP POLICY IF EXISTS "profiles_update_admin" ON public.profiles;

CREATE POLICY "profiles_select_own"
  ON public.profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "profiles_select_admin"
  ON public.profiles FOR SELECT
  USING (is_admin());

CREATE POLICY "profiles_insert_own"
  ON public.profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "profiles_update_own"
  ON public.profiles FOR UPDATE
  USING  (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

CREATE POLICY "profiles_update_admin"
  ON public.profiles FOR UPDATE
  USING (is_admin());

-- Prevent role/status escalation by non-admins
CREATE OR REPLACE FUNCTION prevent_role_escalation()
RETURNS TRIGGER AS $$
BEGIN
  IF NOT is_admin() THEN
    IF NEW.role <> OLD.role THEN
      RAISE EXCEPTION 'Modification du rôle non autorisée' USING ERRCODE = '42501';
    END IF;
    IF NEW.status <> OLD.status THEN
      RAISE EXCEPTION 'Modification du statut non autorisée' USING ERRCODE = '42501';
    END IF;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

DROP TRIGGER IF EXISTS trg_prevent_role_escalation ON public.profiles;
CREATE TRIGGER trg_prevent_role_escalation
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION prevent_role_escalation();

-- ============================================================
-- 8. ORDERS — RLS
-- ============================================================
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "orders_select_own"    ON public.orders;
DROP POLICY IF EXISTS "orders_select_admin"  ON public.orders;
DROP POLICY IF EXISTS "orders_insert_own"    ON public.orders;
DROP POLICY IF EXISTS "orders_update_admin"  ON public.orders;
DROP POLICY IF EXISTS "orders_delete_admin"  ON public.orders;

CREATE POLICY "orders_select_own"
  ON public.orders FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "orders_select_admin"
  ON public.orders FOR SELECT
  USING (is_admin());

CREATE POLICY "orders_insert_own"
  ON public.orders FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "orders_update_admin"
  ON public.orders FOR UPDATE
  USING (is_admin());

CREATE POLICY "orders_delete_admin"
  ON public.orders FOR DELETE
  USING (is_admin());

-- ============================================================
-- 9. TRACKING EVENTS — RLS
-- ============================================================
ALTER TABLE public.tracking_events ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "tracking_select_own"   ON public.tracking_events;
DROP POLICY IF EXISTS "tracking_select_admin" ON public.tracking_events;
DROP POLICY IF EXISTS "tracking_insert_admin" ON public.tracking_events;
DROP POLICY IF EXISTS "tracking_update_admin" ON public.tracking_events;
DROP POLICY IF EXISTS "tracking_delete_admin" ON public.tracking_events;

CREATE POLICY "tracking_select_own"
  ON public.tracking_events FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM public.orders
      WHERE orders.id = tracking_events.order_id
        AND orders.user_id = auth.uid()
    )
  );

CREATE POLICY "tracking_select_admin"
  ON public.tracking_events FOR SELECT
  USING (is_admin());

CREATE POLICY "tracking_insert_admin"
  ON public.tracking_events FOR INSERT
  WITH CHECK (is_admin());

CREATE POLICY "tracking_update_admin"
  ON public.tracking_events FOR UPDATE
  USING (is_admin());

CREATE POLICY "tracking_delete_admin"
  ON public.tracking_events FOR DELETE
  USING (is_admin());

-- ============================================================
-- 10. PAYMENTS — RLS
-- ============================================================
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "payments_select_own"   ON public.payments;
DROP POLICY IF EXISTS "payments_select_admin" ON public.payments;
DROP POLICY IF EXISTS "payments_insert_own"   ON public.payments;
DROP POLICY IF EXISTS "payments_update_admin" ON public.payments;
DROP POLICY IF EXISTS "payments_delete_admin" ON public.payments;

CREATE POLICY "payments_select_own"
  ON public.payments FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "payments_select_admin"
  ON public.payments FOR SELECT
  USING (is_admin());

CREATE POLICY "payments_insert_own"
  ON public.payments FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "payments_update_admin"
  ON public.payments FOR UPDATE
  USING (is_admin());

CREATE POLICY "payments_delete_admin"
  ON public.payments FOR DELETE
  USING (is_admin());

-- ============================================================
-- 11. PRODUCTS — RLS
-- ============================================================
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "products_select_all"  ON public.products;
DROP POLICY IF EXISTS "products_insert_auth" ON public.products;
DROP POLICY IF EXISTS "products_update_admin" ON public.products;

CREATE POLICY "products_select_all"
  ON public.products FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "products_insert_auth"
  ON public.products FOR INSERT
  WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "products_update_admin"
  ON public.products FOR UPDATE
  USING (is_admin());

-- ============================================================
-- 12. NOTIFICATIONS — RLS
-- ============================================================
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "notifications_select_own" ON public.notifications;
DROP POLICY IF EXISTS "notifications_update_own" ON public.notifications;

CREATE POLICY "notifications_select_own"
  ON public.notifications FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "notifications_update_own"
  ON public.notifications FOR UPDATE
  USING (auth.uid() = user_id);

-- ============================================================
-- 13. SETTINGS — RLS
-- ============================================================
ALTER TABLE public.settings ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "settings_select_all"   ON public.settings;
DROP POLICY IF EXISTS "settings_update_admin" ON public.settings;

CREATE POLICY "settings_select_all"
  ON public.settings FOR SELECT
  USING (auth.uid() IS NOT NULL);

CREATE POLICY "settings_update_admin"
  ON public.settings FOR UPDATE
  USING (is_admin());

-- ============================================================
-- 14. ADMIN LOGS — RLS
-- ============================================================
ALTER TABLE public.admin_logs ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin_logs_select_admin" ON public.admin_logs;
DROP POLICY IF EXISTS "admin_logs_insert_admin" ON public.admin_logs;

CREATE POLICY "admin_logs_select_admin"
  ON public.admin_logs FOR SELECT
  USING (is_admin());

CREATE POLICY "admin_logs_insert_admin"
  ON public.admin_logs FOR INSERT
  WITH CHECK (is_admin());

-- ============================================================
-- 15. GRANTS
-- ============================================================
GRANT USAGE ON SCHEMA public TO anon, authenticated;

GRANT SELECT, INSERT, UPDATE          ON public.profiles          TO authenticated;
GRANT SELECT, INSERT, UPDATE          ON public.orders            TO authenticated;
GRANT SELECT, INSERT                  ON public.payments          TO authenticated;
GRANT SELECT                          ON public.tracking_events   TO authenticated;
GRANT SELECT, INSERT, UPDATE          ON public.notifications     TO authenticated;
GRANT SELECT                          ON public.settings          TO authenticated;
GRANT SELECT, INSERT                  ON public.products          TO authenticated;
GRANT SELECT, INSERT                  ON public.admin_logs        TO authenticated;

GRANT USAGE, SELECT ON SEQUENCE order_number_seq TO authenticated;

-- ============================================================
-- 16. INDEXES for performance
-- ============================================================
CREATE INDEX IF NOT EXISTS idx_orders_user_id       ON public.orders(user_id);
CREATE INDEX IF NOT EXISTS idx_orders_status        ON public.orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at    ON public.orders(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_tracking_order_id    ON public.tracking_events(order_id);
CREATE INDEX IF NOT EXISTS idx_tracking_status      ON public.tracking_events(status);
CREATE INDEX IF NOT EXISTS idx_payments_order_id    ON public.payments(order_id);
CREATE INDEX IF NOT EXISTS idx_payments_user_id     ON public.payments(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_status      ON public.payments(status);
CREATE INDEX IF NOT EXISTS idx_notifications_user   ON public.notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_products_platform    ON public.products(platform);
CREATE INDEX IF NOT EXISTS idx_products_category    ON public.products(category);
CREATE INDEX IF NOT EXISTS idx_profiles_role        ON public.profiles(role);
