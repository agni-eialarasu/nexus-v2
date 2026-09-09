# Session Handoff

A short, living snapshot of where the project stands and what's next — so any new
working session (human or AI-assisted) can pick up without re-deriving context.
Keep it brief; update it at the end of a working session.

> This is a pointer, not a source of truth. Authoritative state lives in
> [sprint-tracker.md](sprint-tracker.md), [project-plan.md](project-plan.md), and
> git history.

---

## Current State

- **Phase:** Pre-MVP scaffold + infrastructure. No business features yet — awaiting the first feature scope from the BA (derived from the v1 repo).
- **Frontend:** Flutter Web scaffold. `app/lib/main.dart` renders a single `LoginScreen`; the documented Riverpod/GoRouter/Freezed/Supabase stack is **not yet wired** (deps not in `pubspec.yaml`). Architecture initialization is deliberately **on hold** until the first feature defines the shape.
- **Backend:** `supabase/` has an initial schema migration, an RLS test for tenants, and two Edge Functions (`setup-tenant`, `switch-tenant`). Runs locally via `supabase start`.
- **Environment config:** [`app/lib/core/config/env.dart`](../app/lib/core/config/env.dart) reads `APP_ENV` / `SUPABASE_URL` / `SUPABASE_ANON_KEY` via `--dart-define`. Templates: `app/.env.{local,staging,production}.example`. Local dev uses `--dart-define-from-file=dart_define.local.json` (gitignored).
- **CI:** [`ci.yml`](../.github/workflows/ci.yml) runs analyze + test + format on PRs/pushes to `main`.

## Build & Deploy

- **Staging** = `main` → **GitHub Pages** (auto), `--base-href /nexus-v2/`, via [`deploy-staging.yml`](../.github/workflows/deploy-staging.yml). Live: https://agni-eialarasu.github.io/nexus-v2/
- **Production** = `prod` → **Vercel** (`--base-href /`), via [`deploy-production.yml`](../.github/workflows/deploy-production.yml). Built in GitHub Actions and handed to Vercel prebuilt, to avoid Vercel's locked Dart SDK (the original failure).
  - **Currently INACTIVE:** the `push: [prod]` trigger is commented out; a preflight step fails until Vercel secrets exist.
  - `prod` branch exists locally (created off `main`); not yet pushed.

## What's Next (highest priority)

1. **Wait on BA** for the first feature scope (from v1). Until then, no feature code.
2. **Activate production** when ready: create the Vercel project, add `VERCEL_TOKEN` / `VERCEL_ORG_ID` / `VERCEL_PROJECT_ID` + `PRODUCTION_SUPABASE_*` secrets, uncomment the `push: [prod]` trigger.
3. **Push `prod`** and apply branch protection to both `main` and `prod` (see [DEVELOPMENT.md](DEVELOPMENT.md#branch-protection)).
4. **Architecture initialization** (currently on hold): add Riverpod/GoRouter/Freezed/Supabase deps + the `models/`/`providers/`/`repositories/`/`routing/` skeleton so the first feature has somewhere to land.

## Conventions to remember

- Branch naming, Conventional Commits, sprint protocols, and the Definition of Done are in [DEVELOPMENT.md](DEVELOPMENT.md).
- Never push directly to `main`; the AI never merges its own PR.
- Only the Supabase **anon** key ships in client builds; RLS enforces access.

## Handoff Log

| Date | Session summary |
| :-- | :-- |
| 2026-09-09 | Initialized build/deploy + env strategy + docs (no features). Split deploy into staging (GH Pages / `main`) and production (Vercel / `prod`, inactive). Added `--dart-define` env strategy + `env.dart` + `.env.*.example` templates. Synced dev/doc conventions from `autism-activity-monitor`: `DEVELOPMENT.md`, `CONTRIBUTING.md`, `session-handoff.md`, `product-scope.md`, `architecture.md`. |
