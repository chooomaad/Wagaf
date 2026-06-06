-- ─────────────────────────────────────────────────────────────────────────────
-- Table: import_requests
-- Stores purchase-on-behalf requests submitted by users.
-- Admin fills in the quote; user accepts or refuses.
-- ─────────────────────────────────────────────────────────────────────────────

CREATE TABLE IF NOT EXISTS public.import_requests (
  id             UUID        DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id        UUID        NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  product_url    TEXT        NOT NULL,
  marketplace    TEXT        NOT NULL DEFAULT '',
  status         TEXT        NOT NULL DEFAULT 'pending'
                 CHECK (status IN (
                   'pending', 'analysing', 'quoted', 'approved',
                   'ordered', 'shipping', 'delivered', 'cancelled'
                 )),
  notes          TEXT,
  admin_notes    TEXT,
  quoted_price   NUMERIC(12, 2),
  shipping_price NUMERIC(12, 2),
  service_fee    NUMERIC(12, 2),
  total_price    NUMERIC(12, 2),
  created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS import_requests_user_id_idx ON public.import_requests (user_id);
CREATE INDEX IF NOT EXISTS import_requests_status_idx  ON public.import_requests (status);
CREATE INDEX IF NOT EXISTS import_requests_created_idx ON public.import_requests (created_at DESC);

-- ── Row Level Security ────────────────────────────────────────────────────────

ALTER TABLE public.import_requests ENABLE ROW LEVEL SECURITY;

-- Users read their own requests
CREATE POLICY "Users can read own requests"
  ON public.import_requests FOR SELECT
  USING (auth.uid() = user_id);

-- Users insert their own requests
CREATE POLICY "Users can create own requests"
  ON public.import_requests FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can cancel their own request (update status to 'cancelled' only)
CREATE POLICY "Users can cancel own requests"
  ON public.import_requests FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Admins have full access
CREATE POLICY "Admins have full access to requests"
  ON public.import_requests FOR ALL
  USING (
    EXISTS (
      SELECT 1 FROM public.profiles
      WHERE id = auth.uid()
        AND role IN ('admin', 'super_admin')
    )
  );

-- ── Trigger: updated_at ───────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS import_requests_set_updated_at ON public.import_requests;
CREATE TRIGGER import_requests_set_updated_at
  BEFORE UPDATE ON public.import_requests
  FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
