-- ============================================================================
-- Nexus v2 — Development Seed Data
-- Run with: supabase db reset (applies migrations + seed)
-- ============================================================================

-- Create a demo tenant
INSERT INTO tenants (id, slug, name, code) VALUES
  ('11111111-1111-1111-1111-111111111111', 'acme-corp', 'Acme Corporation', 'ACME2026');

-- Create default roles for the demo tenant
INSERT INTO tenant_roles (tenant_id, name, permissions, is_default) VALUES
  ('11111111-1111-1111-1111-111111111111', 'Project Manager', '{"pages": {"dashboard": {"view": true, "edit": true, "viewMode": "global"}, "projects": {"view": true, "edit": true, "viewMode": "global"}, "portfolios": {"view": true, "edit": true, "viewMode": "global"}, "okrs": {"view": true, "edit": true, "viewMode": "team"}, "financials": {"view": true, "edit": false, "viewMode": "team"}, "capacity": {"view": true, "edit": true, "viewMode": "team"}, "raid": {"view": true, "edit": true, "viewMode": "global"}, "roadmaps": {"view": true, "edit": true, "viewMode": "global"}, "timesheets": {"view": true, "edit": true, "viewMode": "team"}, "team": {"view": true, "edit": false, "viewMode": "team"}, "settings": {"view": true, "edit": false, "viewMode": "own"}}}', false),
  ('11111111-1111-1111-1111-111111111111', 'Team Member', '{"pages": {"dashboard": {"view": true, "edit": false, "viewMode": "own"}, "projects": {"view": true, "edit": false, "viewMode": "team"}, "okrs": {"view": true, "edit": true, "viewMode": "own"}, "timesheets": {"view": true, "edit": true, "viewMode": "own"}, "raid": {"view": true, "edit": true, "viewMode": "own"}}}', true),
  ('11111111-1111-1111-1111-111111111111', 'Viewer', '{"pages": {"dashboard": {"view": true, "edit": false, "viewMode": "own"}, "projects": {"view": true, "edit": false, "viewMode": "own"}}}', false);

-- NOTE: Users are created via Supabase Auth → triggers populate the users table.
-- See supabase/functions/setup-tenant for the full provisioning flow.
