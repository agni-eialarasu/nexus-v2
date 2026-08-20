-- ============================================================================
-- Nexus v2 — Initial Schema
-- Multi-tenant PPM platform with RLS
-- ============================================================================

-- ─── EXTENSIONS ─────────────────────────────────────────────────────────────
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ─── ENUMS ──────────────────────────────────────────────────────────────────
CREATE TYPE user_role AS ENUM ('ADMIN', 'USER', 'VIEWER');
CREATE TYPE user_status AS ENUM ('ACTIVE', 'INACTIVE', 'SUSPENDED');

-- ─── TENANTS ────────────────────────────────────────────────────────────────
CREATE TABLE tenants (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  slug TEXT UNIQUE NOT NULL,
  name TEXT NOT NULL,
  code TEXT UNIQUE NOT NULL,  -- join code for invites
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- ─── TENANT ROLES ───────────────────────────────────────────────────────────
CREATE TABLE tenant_roles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  permissions JSONB,  -- { pages: { dashboard: { view: true, edit: false, viewMode: "global" } } }
  is_default BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),

  UNIQUE(tenant_id, name)
);

CREATE INDEX idx_tenant_roles_tenant ON tenant_roles(tenant_id);

-- ─── USERS ──────────────────────────────────────────────────────────────────
-- Links to Supabase auth.users via id (same UUID)
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  email TEXT NOT NULL,
  display_name TEXT,
  first_name TEXT,
  last_name TEXT,
  avatar_url TEXT,
  job_title TEXT,
  department TEXT,
  location TEXT,
  timezone TEXT,
  phone TEXT,
  role user_role DEFAULT 'USER',
  status user_status DEFAULT 'ACTIVE',
  is_org_admin BOOLEAN DEFAULT false,
  permissions JSONB,  -- user-level permission overrides
  capacity REAL,  -- hours per week
  cost_rate REAL,  -- hourly rate
  manager_id UUID REFERENCES users(id),
  tenant_role_id UUID REFERENCES tenant_roles(id),
  last_login TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),

  UNIQUE(tenant_id, email)
);

CREATE INDEX idx_users_tenant ON users(tenant_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_manager ON users(manager_id);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_status ON users(status);

-- ─── TENANT MEMBERS ─────────────────────────────────────────────────────────
-- Maps users to multiple tenants (for org switching)
CREATE TABLE tenant_members (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  joined_at TIMESTAMPTZ DEFAULT now(),

  UNIQUE(tenant_id, user_id)
);

CREATE INDEX idx_tenant_members_user ON tenant_members(user_id);
CREATE INDEX idx_tenant_members_tenant ON tenant_members(tenant_id);

-- ─── HELPER FUNCTIONS ───────────────────────────────────────────────────────

-- Extract current tenant ID from JWT claims
CREATE OR REPLACE FUNCTION current_tenant_id()
RETURNS UUID AS $$
  SELECT COALESCE(
    (auth.jwt()->'app_metadata'->>'org_id')::UUID,
    '00000000-0000-0000-0000-000000000000'::UUID
  );
$$ LANGUAGE SQL STABLE SECURITY DEFINER;

-- Extract current user ID
CREATE OR REPLACE FUNCTION current_user_id()
RETURNS UUID AS $$
  SELECT auth.uid();
$$ LANGUAGE SQL STABLE;

-- ─── RLS POLICIES ───────────────────────────────────────────────────────────

-- Enable RLS on all tables
ALTER TABLE tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE tenant_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE tenant_members ENABLE ROW LEVEL SECURITY;

-- Tenants: users can only see their own tenant
CREATE POLICY "tenants_select" ON tenants
  FOR SELECT USING (id = current_tenant_id());

-- Tenant Roles: visible within own tenant
CREATE POLICY "tenant_roles_select" ON tenant_roles
  FOR SELECT USING (tenant_id = current_tenant_id());

CREATE POLICY "tenant_roles_manage" ON tenant_roles
  FOR ALL USING (tenant_id = current_tenant_id());

-- Users: visible within own tenant
CREATE POLICY "users_select" ON users
  FOR SELECT USING (tenant_id = current_tenant_id());

CREATE POLICY "users_insert" ON users
  FOR INSERT WITH CHECK (tenant_id = current_tenant_id());

CREATE POLICY "users_update" ON users
  FOR UPDATE USING (tenant_id = current_tenant_id());

-- Tenant Members: users can see their own memberships
CREATE POLICY "tenant_members_own" ON tenant_members
  FOR SELECT USING (user_id = auth.uid());

-- ─── TRIGGERS ───────────────────────────────────────────────────────────────

-- Auto-update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tenants_updated_at
  BEFORE UPDATE ON tenants
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
