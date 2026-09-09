# Development Guide

Everything needed to set up a local environment, run Nexus v2, and contribute
changes. For the product scope and success criteria see
[product-scope.md](product-scope.md); for the intended architecture see
[architecture.md](architecture.md). For a quick "where are we now" snapshot see
[session-handoff.md](session-handoff.md).

---

## 1. Prerequisites

- **Flutter SDK 3.47+** (`flutter --version`). CI pins **3.47.2** — match it locally to avoid surprises. Homebrew: `brew install --cask flutter` (bundles Dart; don't install a separate `dart` formula).
- **Supabase CLI** (`supabase --version`) + **Docker** (for local backend).
- **Node.js 20+** (for Supabase Edge Functions local dev and the Vercel CLI).

---

## 2. Environment Setup

All Flutter commands run from the `app/` directory.

```bash
cd app
flutter pub get
flutter test        # expect green
```

### Environment selection (local / staging / production)

Flutter Web has **no runtime dotenv** — configuration is compiled in at build
time via `--dart-define`. The single source of truth for the resolved
environment is [`app/lib/core/config/env.dart`](../app/lib/core/config/env.dart),
which reads three values:

| Key | Meaning |
| :-- | :-- |
| `APP_ENV` | `local` (default) / `staging` / `production` |
| `SUPABASE_URL` | Supabase project URL for that environment |
| `SUPABASE_ANON_KEY` | Supabase **anon** (publishable) key — never the service-role key |

Each environment has a committed template; copy the values you need into a
gitignored `dart_define.<env>.json` and pass it with `--dart-define-from-file`:

| Env | Template | Local run |
| :-- | :-- | :-- |
| local | [`app/.env.local.example`](../app/.env.local.example) | `flutter run -d chrome --dart-define-from-file=dart_define.local.json` |
| staging | [`app/.env.staging.example`](../app/.env.staging.example) | build with `APP_ENV=staging` (CI does this) |
| production | [`app/.env.production.example`](../app/.env.production.example) | build with `APP_ENV=production` (CI does this) |

A bare `flutter run -d chrome` works too — it resolves to `local` with empty
Supabase config (`Env.hasSupabaseConfig == false`), which is the expected state
until the first backend feature lands.

> `dart_define.*.json` and `.env` files are gitignored; only `*.example`
> templates are committed. **Never commit real keys.** In CI the values come
> from GitHub secrets (see §6).

### Supabase (local backend)

```bash
supabase start        # boots Postgres, Auth, Studio locally (Docker)
supabase db reset     # applies migrations/*.sql + seed.sql
supabase status       # prints local URLs + Publishable/Secret keys
supabase stop
```

Get the local `SUPABASE_ANON_KEY` from `supabase status` (on the current CLI
this is the **Publishable** key, `sb_publishable_...`) and put it in
`app/dart_define.local.json`. Schema/RLS changes are made by adding a new
timestamped migration (`supabase migration new <name>`), never by editing an
applied one.

---

## 3. Running the App

```bash
cd app
flutter run -d chrome                                            # local, no backend
flutter run -d chrome --dart-define-from-file=dart_define.local.json   # local + Supabase
```

Code generation (after adding/changing Freezed models or Riverpod providers):

```bash
cd app
dart run build_runner build --delete-conflicting-outputs
dart run build_runner watch --delete-conflicting-outputs   # continuous
```

---

## 4. Testing & Quality

CI runs three gates on every PR (see [`.github/workflows/ci.yml`](../.github/workflows/ci.yml)).
Run them locally before pushing:

```bash
cd app
flutter analyze --fatal-infos                 # zero warnings/errors
flutter test --coverage                        # all tests pass
dart format --set-exit-if-changed lib/ test/   # consistent formatting
```

**RLS policy tests** live in `supabase/tests/` and run against a local Supabase
(`supabase start`), not in the standard Flutter CI job. Every new/modified table
must ship a corresponding RLS test.

---

## 5. Deployment

Two environments, two branches, two workflows:

| Environment | Branch | Platform | Workflow | base-href |
| :-- | :-- | :-- | :-- | :-- |
| **Staging** | `main` | GitHub Pages | [`deploy-staging.yml`](../.github/workflows/deploy-staging.yml) | `/nexus-v2/` |
| **Production** | `prod` | Vercel | [`deploy-production.yml`](../.github/workflows/deploy-production.yml) | `/` |

```
sprint/N ──PR──▶ main ──auto──▶ GitHub Pages (staging)
                  │
                  └──PR (release)──▶ prod ──auto──▶ Vercel (production)
```

- **Staging** deploys automatically on every push to `main`. Served from a
  subpath, hence `--base-href /nexus-v2/`.
- **Production** deploys on push to `prod`. The build happens **in GitHub
  Actions** (full Flutter SDK control) and the prebuilt static output is handed
  to Vercel — this sidesteps Vercel's locked Dart SDK, the original build
  failure. Served from root, hence `--base-href /`.

> **Production is currently INACTIVE.** The `push: [prod]` trigger is commented
> out and a preflight step fails fast until the Vercel project + secrets exist.
> To activate: create the Vercel project, add the `VERCEL_*` secrets (§6), and
> uncomment the trigger. Details in the workflow header.

### Supabase deployment (backend, manual via CLI)

```bash
supabase db push --linked           # apply migrations
supabase functions deploy setup-tenant
supabase functions deploy switch-tenant
```

---

## 6. CI/CD Secrets

Set at **Settings → Secrets and variables → Actions**. All optional until the
feature that needs them lands; workflows tolerate their absence.

| Secret | Used by | Purpose |
| :-- | :-- | :-- |
| `STAGING_SUPABASE_URL` / `STAGING_SUPABASE_ANON_KEY` | staging build | Supabase config baked into the staging web build |
| `PRODUCTION_SUPABASE_URL` / `PRODUCTION_SUPABASE_ANON_KEY` | production build | Supabase config baked into the production web build |
| `VERCEL_TOKEN` / `VERCEL_ORG_ID` / `VERCEL_PROJECT_ID` | production deploy | Authenticate + target the Vercel project |

> Only the Supabase **anon** key ever ships in a client build — RLS enforces
> access. The service-role key stays server-side (Edge Function secrets via
> `supabase secrets set`).

---

## 7. Development Workflow

1. **Sync** `main`: `git checkout main && git pull`.
2. **Branch** off `main` using the naming convention below.
3. **Implement** — keep commits focused; follow project conventions (every table
   has `tenant_id` + RLS; providers use `@riverpod`; models use Freezed; no
   hardcoded strings; responsive at all three breakpoints).
4. **Verify** locally — analyze + test + format green (§4).
5. **Update docs** for any behavior change (architecture, product-scope, tracker).
6. **Open a PR** into `main`. Never push directly to `main`.

### Branch Protection

`main` (and eventually `prod`) should be protected. Configure once at
**Settings → Branches → Add branch ruleset** for `main`:

- [ ] **Require a pull request before merging** (≥1 approval; dismiss stale approvals on new commits).
- [ ] **Require status checks to pass** — select the CI job from [`ci.yml`](../.github/workflows/ci.yml) (appears in the list only after the workflow has run once).
- [ ] **Require branches to be up to date** before merging.
- [ ] **Require conversation resolution** before merging.
- [ ] **Do not allow force pushes**; **do not allow deletions**.
- [ ] Apply the same ruleset to `prod` once production is live.

> Solo/admin exception: while there is a single maintainer you may keep "include
> administrators" off so doc-only changes can merge directly. Turn it on when
> the team grows.

### Roles: AI implementer vs. Owner

The one firm boundary: **the AI never merges its own PR.** It opens the PR and
closes out afterward; the Owner reviews and merges.

| Step | AI implementer | Owner |
| :-- | :--: | :--: |
| Agree sprint scope | proposes | decides |
| Branch, implement, tests/docs | ✅ | |
| Local checks green + push + open PR | ✅ | |
| Watch CI; fix + re-push if red | ✅ | |
| Review + **merge** the PR | | ✅ |
| Close out: sync `main`, delete branch | ✅ | |

---

## 8. Branch Naming Strategy

`type/short-description` in kebab-case.

| Type | Use for | Example |
| :-- | :-- | :-- |
| `sprint/` | A full sprint's feature work | `sprint/3-projects-crud` |
| `feat/` | A single user-facing capability | `feat/project-milestones` |
| `fix/` | Bug fix | `fix/tenant-slug-routing` |
| `docs/` | Documentation only | `docs/session-handoff` |
| `refactor/` | Restructure, no behavior change | `refactor/rbac-provider` |
| `test/` | Test-only additions | `test/rls-portfolios` |
| `chore/` | Tooling, deps, housekeeping | `chore/init-build-deploy-docs` |

Keep names lowercase, hyphen-separated, short. One branch per logical change.
Delete merged branches to keep the list clean.

## 9. Commit Message Convention

Follow [Conventional Commits](https://www.conventionalcommits.org/):
`type(scope): summary`.

```text
feat(projects): add project CRUD screen
fix(routing): correct tenant-scoped redirect
chore(ci): add production Vercel workflow (inactive)
docs(dev): document staging/prod deploy split
```

Same `type` vocabulary as the branch table. Keep the summary under ~70
characters; use the body for rationale.

---

## 10. Sprint Protocols

Three lightweight protocols separate **code delivery** from **clerical docs** so
doc-heavy updates never destabilize a code PR.

**`sprint-start`** — create `sprint/N-<topic>` off `main`, mark the sprint
🚧 In Progress in [sprint-tracker.md](sprint-tracker.md), begin implementation.

**`sprint-finish`** — run the full local suite green, push, open the PR into
`main`, watch CI to green (fix on the same branch if red — never merge red). The
Owner reviews and merges. On "PR #N merged", the AI syncs `main` and deletes the
branch.

**`sprint-update`** — on a separate `docs/sprintN-update` branch after merge,
refresh the tracker (set ✅, record Owner), session-handoff, and any affected
scope/architecture docs. Doc-only; may merge directly.

**`release-start` / `release-finish`** — promote `main` → `prod` via PR after a
staging smoke check; merging to `prod` triggers the production (Vercel) deploy.

### Sprint Delivery Checklist (Definition of Done)

A sprint is not "done" until every item holds:

- [ ] **Code merged** to `main` via PR.
- [ ] **PR link** recorded in the tracker.
- [ ] **Docs updated** — architecture / product-scope / tracker as applicable.
- [ ] **Tests green** — new behavior covered; `flutter analyze`, `flutter test`,
      `dart format` all pass; RLS tests for any new/changed table.
- [ ] **No hardcoded strings** (i18n-ready); responsive at all three breakpoints.
- [ ] **Tracker updated** — status ✅ and Owner recorded.
