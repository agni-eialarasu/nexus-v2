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

- `/sprint-start` — Create `sprint/N-<topic>` branch off `main`, update tracker
- `/sprint-finish` — Push, open PR into `main`, update tracker
- `/sprint-update` — Post-merge documentation (separate `docs/` branch)
- `/release-start` / `/release-finish` — Promote `main` → `prod` (staging smoke check → production deploy)
- Branches: `sprint/`, `feat/`, `fix/`, `docs/`, `refactor/`, `test/`, `chore/` (kebab-case); commits follow Conventional Commits
- Never push directly to `main`
- Developer is sole merge authority (the AI never merges its own PR)

See `docs/DEVELOPMENT.md` §8–10 for the full branch/commit/sprint reference.

## Supabase Rules

- Direct client access for simple CRUD (RLS handles auth)
- Edge Functions for multi-step operations (tenant setup, role assignment)
- Realtime subscriptions via StreamProvider
- All RLS policies must be tested (SQL tests in supabase/tests/)

## Environments & Deploy

- **Staging:** `main` → GitHub Pages (auto), `--base-href /nexus-v2/`
- **Production:** `prod` → Vercel, `--base-href /` (built in GitHub Actions, handed to Vercel prebuilt)
- **Config:** compile-time via `--dart-define` (`APP_ENV`, `SUPABASE_URL`, `SUPABASE_ANON_KEY`) resolved in `app/lib/core/config/env.dart`; no runtime dotenv. Local dev uses `--dart-define-from-file=dart_define.local.json` (gitignored)
- Only the Supabase **anon** key ships in client builds; service-role key stays server-side

See `docs/DEVELOPMENT.md` §5–6 for deploy + secrets detail.
