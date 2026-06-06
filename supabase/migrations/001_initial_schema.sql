-- ============================================================
-- SALAM APP - Initial Database Schema
-- ============================================================

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================
-- ENUMS
-- ============================================================

CREATE TYPE user_role AS ENUM ('user', 'admin', 'super_admin');
CREATE TYPE user_status AS ENUM ('active', 'suspended', 'deleted');
CREATE TYPE order_status AS ENUM (
  'pending',
  'payment_validated',
  'purchased',
  'in_transit',
  'arrived_mauritania',
  'delivered',
  'cancelled',
  'refunded'
);
CREATE TYPE payment_status AS ENUM ('pending', 'validated', 'rejected', 'refunded');
CREATE TYPE payment_method AS ENUM ('bankily', 'masrivi', 'manual', 'other');
CREATE TYPE platform AS ENUM ('aliexpress', 'alibaba', 'amazon', 'temu', 'other');
CREATE TYPE notification_type AS ENUM (
  'order_created',
  'payment_validated',
  'order_purchased',
  'order_in_transit',
  'order_arrived',
  'order_delivered',
  'order_cancelled',
  'system'
);

-- ============================================================
-- TABLE: profiles (extends auth.users)
-- ============================================================

CREATE TABLE public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  full_name TEXT,
  phone TEXT,
  city TEXT,
  avatar_url TEXT,
  role user_role NOT NULL DEFAULT 'user',
  status user_status NOT NULL DEFAULT 'active',
  fcm_token TEXT,
  preferred_language TEXT DEFAULT 'fr',
  total_orders INT DEFAULT 0,
  total_spent DECIMAL(10,2) DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TABLE: products (product catalog / cache)
-- ============================================================

CREATE TABLE public.products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  external_url TEXT NOT NULL,
  platform platform NOT NULL DEFAULT 'other',
  title TEXT NOT NULL,
  description TEXT,
  price DECIMAL(10,2) NOT NULL DEFAULT 0,
  currency TEXT NOT NULL DEFAULT 'USD',
  images TEXT[] DEFAULT '{}',
  category TEXT,
  rating DECIMAL(3,2),
  reviews_count INT DEFAULT 0,
  is_available BOOLEAN DEFAULT true,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(external_url)
);

-- ============================================================
-- TABLE: orders
-- ============================================================

CREATE TABLE public.orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_number TEXT UNIQUE NOT NULL,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
  status order_status NOT NULL DEFAULT 'pending',

  -- Product info snapshot
  product_url TEXT NOT NULL,
  platform platform NOT NULL DEFAULT 'other',
  product_title TEXT NOT NULL,
  product_image TEXT,
  product_price DECIMAL(10,2) NOT NULL DEFAULT 0,
  product_currency TEXT NOT NULL DEFAULT 'USD',
  quantity INT NOT NULL DEFAULT 1,

  -- Pricing (in MRU)
  product_price_mru DECIMAL(10,2) NOT NULL DEFAULT 0,
  shipping_fee_mru DECIMAL(10,2) NOT NULL DEFAULT 0,
  service_fee_mru DECIMAL(10,2) NOT NULL DEFAULT 0,
  total_mru DECIMAL(10,2) NOT NULL DEFAULT 0,

  -- Admin fields
  admin_notes TEXT,
  weight_kg DECIMAL(5,2),
  tracking_number TEXT,
  carrier TEXT,

  -- Dates
  paid_at TIMESTAMPTZ,
  purchased_at TIMESTAMPTZ,
  shipped_at TIMESTAMPTZ,
  arrived_at TIMESTAMPTZ,
  delivered_at TIMESTAMPTZ,
  cancelled_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Auto-generate order number
CREATE SEQUENCE IF NOT EXISTS order_number_seq START 1000;
ALTER TABLE public.orders
  ALTER COLUMN order_number
  SET DEFAULT 'SLM-' || TO_CHAR(NOW(), 'YYYYMMDD') || '-' || LPAD(NEXTVAL('order_number_seq')::TEXT, 4, '0');

-- ============================================================
-- TABLE: payments
-- ============================================================

CREATE TABLE public.payments (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
  amount DECIMAL(10,2) NOT NULL,
  currency TEXT NOT NULL DEFAULT 'MRU',
  method payment_method NOT NULL DEFAULT 'manual',
  status payment_status NOT NULL DEFAULT 'pending',
  reference TEXT,
  proof_url TEXT,
  admin_notes TEXT,
  validated_by UUID REFERENCES public.profiles(id),
  validated_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TABLE: tracking_events
-- ============================================================

CREATE TABLE public.tracking_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  order_id UUID NOT NULL REFERENCES public.orders(id) ON DELETE CASCADE,
  status order_status NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  location TEXT,
  created_by UUID REFERENCES public.profiles(id),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TABLE: notifications
-- ============================================================

CREATE TABLE public.notifications (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  type notification_type NOT NULL DEFAULT 'system',
  title TEXT NOT NULL,
  body TEXT NOT NULL,
  data JSONB DEFAULT '{}',
  is_read BOOLEAN DEFAULT false,
  read_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TABLE: admin_logs
-- ============================================================

CREATE TABLE public.admin_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  admin_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE RESTRICT,
  action TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id UUID,
  old_data JSONB,
  new_data JSONB,
  ip_address TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TABLE: settings
-- ============================================================

CREATE TABLE public.settings (
  key TEXT PRIMARY KEY,
  value JSONB NOT NULL,
  description TEXT,
  updated_by UUID REFERENCES public.profiles(id),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Default settings
INSERT INTO public.settings (key, value, description) VALUES
  ('service_fee_percent', '15', 'Service fee percentage applied to all orders'),
  ('min_shipping_fee_mru', '500', 'Minimum shipping fee in MRU'),
  ('usd_to_mru_rate', '37', 'USD to MRU exchange rate'),
  ('app_maintenance', 'false', 'Maintenance mode flag'),
  ('supported_platforms', '["aliexpress","alibaba","amazon","temu"]', 'Supported shopping platforms');

-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX idx_orders_user_id ON public.orders(user_id);
CREATE INDEX idx_orders_status ON public.orders(status);
CREATE INDEX idx_orders_created_at ON public.orders(created_at DESC);
CREATE INDEX idx_payments_order_id ON public.payments(order_id);
CREATE INDEX idx_payments_user_id ON public.payments(user_id);
CREATE INDEX idx_payments_status ON public.payments(status);
CREATE INDEX idx_tracking_order_id ON public.tracking_events(order_id);
CREATE INDEX idx_notifications_user_id ON public.notifications(user_id);
CREATE INDEX idx_notifications_is_read ON public.notifications(user_id, is_read);
CREATE INDEX idx_admin_logs_admin_id ON public.admin_logs(admin_id);
CREATE INDEX idx_admin_logs_entity ON public.admin_logs(entity_type, entity_id);

-- ============================================================
-- FUNCTIONS & TRIGGERS
-- ============================================================

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_profiles_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_orders_updated_at
  BEFORE UPDATE ON public.orders
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER trg_payments_updated_at
  BEFORE UPDATE ON public.payments
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Auto-create profile on user signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1))
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Auto-create tracking event on order status change
CREATE OR REPLACE FUNCTION handle_order_status_change()
RETURNS TRIGGER AS $$
DECLARE
  status_titles JSONB := '{
    "pending": "Commande reçue",
    "payment_validated": "Paiement validé",
    "purchased": "Produit acheté",
    "in_transit": "En transit",
    "arrived_mauritania": "Arrivé en Mauritanie",
    "delivered": "Livré",
    "cancelled": "Commande annulée",
    "refunded": "Remboursé"
  }';
BEGIN
  IF NEW.status <> OLD.status THEN
    INSERT INTO public.tracking_events (order_id, status, title)
    VALUES (
      NEW.id,
      NEW.status,
      COALESCE(status_titles->>NEW.status::TEXT, NEW.status::TEXT)
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_order_status_tracking
  AFTER UPDATE OF status ON public.orders
  FOR EACH ROW EXECUTE FUNCTION handle_order_status_change();

-- Update profile totals when order delivered
CREATE OR REPLACE FUNCTION update_profile_totals()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.status = 'delivered' AND OLD.status <> 'delivered' THEN
    UPDATE public.profiles
    SET
      total_orders = total_orders + 1,
      total_spent = total_spent + NEW.total_mru
    WHERE id = NEW.user_id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_profile_totals
  AFTER UPDATE OF status ON public.orders
  FOR EACH ROW EXECUTE FUNCTION update_profile_totals();
