# Contributing

A short onboarding checklist for a new team member's first sprint. The full
details live in the [Development Guide](docs/DEVELOPMENT.md); this is the fast
path.

## First-day setup

- [ ] Read the [Session Handoff](docs/session-handoff.md) — where the project stands and what's next.
- [ ] Skim the [Product Scope](docs/product-scope.md) and [Architecture](docs/architecture.md) — the *what/why* and the *how*.
- [ ] Set up your environment (see [Development Guide §2](docs/DEVELOPMENT.md#2-environment-setup)):
  ```bash
  cd app
  flutter pub get
  flutter test          # expect all tests green
  ```
- [ ] For local backend work, start Supabase and wire local config:
  ```bash
  supabase start
  supabase status       # copy the anon key into app/dart_define.local.json
  ```
  Never commit `dart_define.*.json` or `.env` files — only the `*.example` templates.

## Before you start work

- [ ] Confirm your **sprint and Owner** in the [Sprint Tracker](docs/sprint-tracker.md).

## Doing the work (per sprint)

- [ ] Branch off `main`: `sprint/N-<topic>` or `feat/<topic>` (see [branch naming](docs/DEVELOPMENT.md#8-branch-naming-strategy)).
- [ ] Follow [Conventional Commits](docs/DEVELOPMENT.md#9-commit-message-convention): `type(scope): summary`.
- [ ] Add/update tests for any behavior change; keep `flutter test` green.
- [ ] Every new table gets `tenant_id` + an RLS policy + an RLS test.
- [ ] No hardcoded strings (i18n-ready); screens work at all three breakpoints.
- [ ] Update docs for any behavior change (architecture, tracker).

## Before you open a PR

- [ ] Local checks pass: `flutter analyze --fatal-infos`, `flutter test`, `dart format --set-exit-if-changed lib/ test/`.
- [ ] Walk the [Sprint Delivery Checklist](docs/DEVELOPMENT.md#sprint-delivery-checklist-definition-of-done) — it's the Definition of Done.
- [ ] Open a PR into `main`. **CI must pass** and the **Owner must approve** before merge. Do not merge your own PR.

## Notes for this project

- **Product code goes through PRs** (reviewed before merge). Doc-only changes may merge directly per current policy — when in doubt, use a PR.
- **Staging** = `main` → GitHub Pages (auto). **Production** = `prod` → Vercel (auto, currently inactive until Vercel is set up).
- The Flutter app lives in `app/`; the backend (`supabase/`) has schema + RLS + Edge Functions. Feature modules land under `app/lib/features/` as the BA's scope firms up.
