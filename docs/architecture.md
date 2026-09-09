# Architecture — Nexus v2

The *how* of Nexus v2. For the *what/why*, see [product-scope.md](product-scope.md).
For setup and workflow, see [DEVELOPMENT.md](DEVELOPMENT.md).

> **Status: intended architecture.** This documents the target design. Much of
> the Flutter side is **not yet implemented** — the app is currently a scaffold
> (`main.dart` shows a `LoginScreen`); the stack below lands with the first
> feature. Sections marked _(planned)_ are not built yet.

---

## 1. Stack

| Layer | Technology |
| :-- | :-- |
| UI | Flutter Web (responsive: small <600, medium 600–1024, large >1024) |
| State | Riverpod 3 with code generation (`@riverpod`) _(planned)_ |
| Routing | GoRouter, tenant-scoped `/org/:slug/...` _(planned)_ |
| Models | Freezed + json_serializable _(planned)_ |
| Backend | Supabase (Auth, PostgreSQL, Realtime, Edge Functions) |
| Multi-tenancy | Shared schema + RLS + JWT claims (`app_metadata.org_id`) |
| RBAC | Page/action/view-mode permissions |
| Testing | flutter_test + mocktail; pgTAP-style SQL for RLS |

## 2. Multi-Tenancy Model

- **Shared schema.** Every table carries `tenant_id` and a matching RLS policy.
- **JWT claims.** The active org is carried in `app_metadata.org_id`; RLS
  policies filter rows by it.
- **Tenant switching.** Handled server-side by the `switch-tenant` Edge Function
  (updates claims); provisioning by `setup-tenant`.

## 3. RBAC

Effective permission precedence: `isOrgAdmin > TenantRole > User overrides`.
Permissions are evaluated per page, per action, and per view mode
(own / team / global). Sidebar items and routes are filtered by the resolved
permission set. _(Resolution logic: planned.)_

## 4. Frontend Structure (target)

Feature-first under `app/lib/features/<feature>/` with `models/`, `providers/`,
`screens/`, `widgets/`. Shared code under `app/lib/`: `core/` (theme, constants,
config, shared widgets), `models/`, `providers/` (auth, supabase, rbac, tenant),
`repositories/` (data access), `routing/` (GoRouter + app shell).

**Implemented today:** `core/theme/`, `core/constants/`,
`core/config/env.dart`, `features/auth/screens/login_screen.dart`, `main.dart`.
The rest is _(planned)_ and arrives with feature work.

## 5. Backend Structure

- `supabase/migrations/` — numbered SQL migrations (schema + RLS). Never edit an
  applied migration; add a new one.
- `supabase/functions/` — Edge Functions for multi-step operations
  (`setup-tenant`, `switch-tenant`).
- `supabase/tests/` — RLS policy tests; every new/changed table ships one.
- `supabase/seed.sql` — local dev seed.

**Data access rule of thumb:** direct Supabase client for simple CRUD (RLS
handles auth); Edge Functions for multi-step operations; Realtime via
`StreamProvider`.

## 6. Environments & Config

Compile-time config via `--dart-define`, resolved in
[`app/lib/core/config/env.dart`](../app/lib/core/config/env.dart)
(`APP_ENV` / `SUPABASE_URL` / `SUPABASE_ANON_KEY`). Staging → GitHub Pages
(`main`), Production → Vercel (`prod`). See [DEVELOPMENT.md §5](DEVELOPMENT.md#5-deployment).

## 7. Decisions & Rationale

- **Flutter Web over React rebuild:** single codebase, strong typing, room to
  reach mobile later.
- **Supabase over custom NestJS:** managed Auth + Postgres + RLS + Realtime
  reduces backend surface; RLS keeps tenant isolation close to the data.
- **GitHub Actions build for Vercel:** full Flutter SDK control; avoids Vercel's
  locked Dart SDK, which was the original production build blocker.
