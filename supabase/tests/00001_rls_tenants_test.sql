-- ============================================================================
-- RLS Policy Tests — Tenant Isolation
-- Run with: supabase test db
--
-- pgTAP suite verifying that the `tenants` and `tenant_roles` RLS policies
-- scope every read to the caller's own tenant (via current_tenant_id(), which
-- reads app_metadata.org_id from the JWT claims).
-- ============================================================================

BEGIN;

SELECT plan(6);

-- ─── Fixtures ───────────────────────────────────────────────────────────────
-- Seed already inserts Tenant A (11111111...). Add a second tenant + a role in
-- each so cross-tenant leakage is observable. Inserted as the table owner here
-- (RLS is not enforced for the superuser running the test setup).
INSERT INTO tenants (id, slug, name, code) VALUES
  ('22222222-2222-2222-2222-222222222222', 'globex', 'Globex', 'GLOBEX01')
  ON CONFLICT (id) DO NOTHING;

INSERT INTO tenant_roles (tenant_id, name) VALUES
  ('22222222-2222-2222-2222-222222222222', 'B-Only Role')
  ON CONFLICT (tenant_id, name) DO NOTHING;

-- ─── Act as an authenticated user in Tenant A ─────────────────────────────────
SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claims =
  '{"sub": "00000000-0000-0000-0000-00000000000a", "role": "authenticated", "app_metadata": {"org_id": "11111111-1111-1111-1111-111111111111"}}';

-- current_tenant_id() resolves from the JWT claim.
SELECT is(
  current_tenant_id(),
  '11111111-1111-1111-1111-111111111111'::uuid,
  'current_tenant_id() reads org_id from JWT claims'
);

-- Tenant A sees exactly its own tenant row...
SELECT is(
  (SELECT count(*) FROM tenants),
  1::bigint,
  'tenant sees exactly one tenant row (its own)'
);

-- ...and never Tenant B.
SELECT is(
  (SELECT count(*) FROM tenants WHERE id = '22222222-2222-2222-2222-222222222222'),
  0::bigint,
  'tenant cannot see a different tenant (RLS filters it out)'
);

-- Roles are scoped to the caller's tenant: none of Tenant B's roles are visible.
SELECT is(
  (SELECT count(*) FROM tenant_roles WHERE tenant_id = '22222222-2222-2222-2222-222222222222'),
  0::bigint,
  'tenant cannot see another tenant''s roles'
);

-- ─── Switch to Tenant B ───────────────────────────────────────────────────────
SET LOCAL request.jwt.claims =
  '{"sub": "00000000-0000-0000-0000-00000000000b", "role": "authenticated", "app_metadata": {"org_id": "22222222-2222-2222-2222-222222222222"}}';

-- Tenant B now sees its own tenant row (and not Tenant A's).
SELECT is(
  (SELECT count(*) FROM tenants WHERE id = '22222222-2222-2222-2222-222222222222'),
  1::bigint,
  'switching tenants reveals only the new tenant'
);

SELECT is(
  (SELECT count(*) FROM tenants WHERE id = '11111111-1111-1111-1111-111111111111'),
  0::bigint,
  'Tenant B cannot see Tenant A'
);

SELECT * FROM finish();

ROLLBACK;
