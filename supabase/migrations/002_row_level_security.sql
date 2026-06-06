-- ============================================================
-- SALAM APP - Row Level Security Policies
-- ============================================================

-- Enable RLS on all tables
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.tracking_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.admin_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.settings ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- Helper function: check if current user is admin
-- ============================================================

CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid()
    AND role IN ('admin', 'super_admin')
    AND status = 'active'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

CREATE OR REPLACE FUNCTION is_super_admin()
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = auth.uid()
    AND role = 'super_admin'
    AND status = 'active'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER STABLE;

-- ============================================================
-- PROFILES POLICIES
-- ============================================================

-- Users can read their own profile
CREATE POLICY "profiles_select_own" ON public.profiles
  FOR SELECT USING (auth.uid() = id);

-- Admins can read all profiles
CREATE POLICY "profiles_select_admin" ON public.profiles
  FOR SELECT USING (is_admin());

-- Users can update their own profile (limited fields)
CREATE POLICY "profiles_update_own" ON public.profiles
  FOR UPDATE USING (auth.uid() = id)
  WITH CHECK (
    auth.uid() = id
    AND role = (SELECT role FROM public.profiles WHERE id = auth.uid())
    AND status = (SELECT status FROM public.profiles WHERE id = auth.uid())
  );

-- Admins can update any profile
CREATE POLICY "profiles_update_admin" ON public.profiles
  FOR UPDATE USING (is_admin());

-- ============================================================
-- PRODUCTS POLICIES
-- ============================================================

-- Everyone authenticated can read products
CREATE POLICY "products_select_all" ON public.products
  FOR SELECT USING (auth.role() = 'authenticated');

-- Only admins can insert/update/delete products
CREATE POLICY "products_insert_admin" ON public.products
  FOR INSERT WITH CHECK (is_admin());

CREATE POLICY "products_update_admin" ON public.products
  FOR UPDATE USING (is_admin());

CREATE POLICY "products_delete_admin" ON public.products
  FOR DELETE USING (is_admin());

-- ============================================================
-- ORDERS POLICIES
-- ============================================================

-- Users can read their own orders
CREATE POLICY "orders_select_own" ON public.orders
  FOR SELECT USING (auth.uid() = user_id);

-- Admins can read all orders
CREATE POLICY "orders_select_admin" ON public.orders
  FOR SELECT USING (is_admin());

-- Users can create their own orders
CREATE POLICY "orders_insert_own" ON public.orders
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Users can cancel their own pending orders
CREATE POLICY "orders_update_own" ON public.orders
  FOR UPDATE USING (
    auth.uid() = user_id
    AND status = 'pending'
  )
  WITH CHECK (
    auth.uid() = user_id
    AND status = 'cancelled'
  );

-- Admins can update any order
CREATE POLICY "orders_update_admin" ON public.orders
  FOR UPDATE USING (is_admin());

-- ============================================================
-- PAYMENTS POLICIES
-- ============================================================

-- Users can read their own payments
CREATE POLICY "payments_select_own" ON public.payments
  FOR SELECT USING (auth.uid() = user_id);

-- Admins can read all payments
CREATE POLICY "payments_select_admin" ON public.payments
  FOR SELECT USING (is_admin());

-- Users can create payments for their own orders
CREATE POLICY "payments_insert_own" ON public.payments
  FOR INSERT WITH CHECK (
    auth.uid() = user_id
    AND EXISTS (
      SELECT 1 FROM public.orders
      WHERE id = order_id AND user_id = auth.uid()
    )
  );

-- Only admins can validate/reject payments
CREATE POLICY "payments_update_admin" ON public.payments
  FOR UPDATE USING (is_admin());

-- ============================================================
-- TRACKING EVENTS POLICIES
-- ============================================================

-- Users can read tracking for their orders
CREATE POLICY "tracking_select_own" ON public.tracking_events
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.orders
      WHERE id = order_id AND user_id = auth.uid()
    )
  );

-- Admins can read all tracking events
CREATE POLICY "tracking_select_admin" ON public.tracking_events
  FOR SELECT USING (is_admin());

-- Only admins can insert tracking events
CREATE POLICY "tracking_insert_admin" ON public.tracking_events
  FOR INSERT WITH CHECK (is_admin());

-- ============================================================
-- NOTIFICATIONS POLICIES
-- ============================================================

-- Users can read their own notifications
CREATE POLICY "notifications_select_own" ON public.notifications
  FOR SELECT USING (auth.uid() = user_id);

-- Users can mark their own notifications as read
CREATE POLICY "notifications_update_own" ON public.notifications
  FOR UPDATE USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Admins can insert notifications for any user
CREATE POLICY "notifications_insert_admin" ON public.notifications
  FOR INSERT WITH CHECK (is_admin() OR auth.uid() = user_id);

-- ============================================================
-- ADMIN LOGS POLICIES
-- ============================================================

-- Only admins can read logs
CREATE POLICY "admin_logs_select_admin" ON public.admin_logs
  FOR SELECT USING (is_admin());

-- Only admins can insert logs
CREATE POLICY "admin_logs_insert_admin" ON public.admin_logs
  FOR INSERT WITH CHECK (is_admin());

-- ============================================================
-- SETTINGS POLICIES
-- ============================================================

-- Everyone authenticated can read settings
CREATE POLICY "settings_select_all" ON public.settings
  FOR SELECT USING (auth.role() = 'authenticated');

-- Only super_admins can update settings
CREATE POLICY "settings_update_super_admin" ON public.settings
  FOR UPDATE USING (is_super_admin());

CREATE POLICY "settings_insert_super_admin" ON public.settings
  FOR INSERT WITH CHECK (is_super_admin());

-- ============================================================
-- Realtime subscriptions
-- ============================================================

ALTER PUBLICATION supabase_realtime ADD TABLE public.orders;
ALTER PUBLICATION supabase_realtime ADD TABLE public.tracking_events;
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
ALTER PUBLICATION supabase_realtime ADD TABLE public.payments;
