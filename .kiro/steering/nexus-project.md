# Nexus v2 — Kiro Steering Rules

## Project Context

Nexus v2 is a multi-tenant PPM (Project Portfolio Management) platform built with Flutter Web + Supabase. It's a greenfield rebuild of an existing React/NestJS application.

## Stack

- **Frontend:** Flutter Web (responsive: small < 600px, medium 600-1024px, large > 1024px)
- **State Management:** Riverpod 3 with code generation (@riverpod annotation)
- **Routing:** GoRouter (tenant-scoped: /org/:slug/...)
- **Backend:** Supabase (Auth, PostgreSQL, Realtime, Edge Functions)
- **Database:** PostgreSQL with RLS (Row Level Security)
- **Multi-tenancy:** Shared schema + RLS + JWT claims (app_metadata.org_id)
- **RBAC:** Page/action/view-mode permissions (isOrgAdmin > TenantRole > User overrides)
- **Models:** Freezed + json_serializable
- **Testing:** mocktail for mocks

## Code Organization

Feature-first structure under `app/lib/features/<feature>/`:
- `models/` — Freezed data classes
- `providers/` — Riverpod providers (annotated)
- `screens/` — Page-level widgets
- `widgets/` — Feature-specific reusable widgets

Shared code under `app/lib/`:
- `core/` — Theme, constants, utilities, shared widgets
- `models/` — Cross-feature models (Tenant, Permissions)
- `providers/` — Global providers (auth, supabase, rbac, tenant)
- `repositories/` — Data access layer (abstracts Supabase calls)
- `routing/` — GoRouter config and app shell

## Conventions

1. **Every table must have `tenant_id`** and a corresponding RLS policy
2. **Every new provider uses `@riverpod` annotation** (code generation)
3. **Every model uses Freezed** with `fromJson`/`toJson`
4. **Every PR must include tests** for new functionality
5. **No hardcoded strings** — prepare for i18n from day one
6. **Responsive design** — all screens must work at all 3 breakpoints
7. **RBAC-gated navigation** — sidebar items and routes filtered by permissions

## Sprint Protocol

- `/sprint-start` — Create branch, update tracker
- `/sprint-finish` — Push, create PR, update tracker
- `/sprint-update` — Post-merge documentation
- Never push directly to main
- Developer is sole merge authority

## Supabase Rules

- Direct client access for simple CRUD (RLS handles auth)
- Edge Functions for multi-step operations (tenant setup, role assignment)
- Realtime subscriptions via StreamProvider
- All RLS policies must be tested (SQL tests in supabase/tests/)
