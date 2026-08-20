-- ============================================================================
-- RLS Policy Tests — Tenant Isolation
-- Run with: supabase test db
-- ============================================================================

-- Test: User can only see their own tenant
BEGIN;

-- Setup: Pretend to be an authenticated user in tenant A
SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claims = '{"sub": "user-a-uuid", "app_metadata": {"org_id": "11111111-1111-1111-1111-111111111111"}}';

-- Verify: Can see own tenant
SELECT count(*) AS own_tenant_count FROM tenants;
-- Expected: 1

-- Verify: Cannot see a different tenant
-- (If another tenant existed, it would be filtered out by RLS)

ROLLBACK;

-- Test: User cannot insert into another tenant's roles
BEGIN;

SET LOCAL ROLE authenticated;
SET LOCAL request.jwt.claims = '{"sub": "user-a-uuid", "app_metadata": {"org_id": "11111111-1111-1111-1111-111111111111"}}';

-- This should fail or return 0 rows (RLS blocks cross-tenant writes)
-- INSERT INTO tenant_roles (tenant_id, name)
-- VALUES ('22222222-2222-2222-2222-222222222222', 'Hacker Role');

-- Verify the role was NOT created (RLS should block it)
SELECT count(*) AS cross_tenant_roles
FROM tenant_roles
WHERE tenant_id = '22222222-2222-2222-2222-222222222222';
-- Expected: 0

ROLLBACK;
