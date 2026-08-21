# Development Workflow

## Sprint Protocol

| Command | Action |
|---------|--------|
| `/sprint-start` | Create `sprint/N` branch from main, update tracker |
| `/sprint-finish` | Push branch, create PR, update tracker |
| `/sprint-update` | Post-merge docs update (valuation, evaluation) |
| `/release-start` | Staging smoke test verification |
| `/release-finish` | Production promotion |

## Branching Strategy

```
main (protected) ─── auto-deploys to GitHub Pages
  │
  ├── sprint/N ─── feature implementation
  │     └── PR → main
  │
  ├── hotfix/description ─── urgent fixes
  │     └── PR → main
  │
  └── docs/description ─── documentation only
        └── PR → main
```

## Rules

- **main** is always deployable
- All changes go through PRs (even solo — creates audit trail + CI gate)
- Never push directly to main
- Sprint branches for all implementation work
- Only the developer merges PRs

## CI/CD Pipeline

### CI (on every PR to main)

| Step | Command | Requirement |
|------|---------|-------------|
| 1 | `flutter analyze --fatal-infos` | Zero warnings/errors |
| 2 | `flutter test --coverage` | All tests must pass |
| 3 | `dart format --set-exit-if-changed lib/ test/` | Consistent formatting |

### Deploy (on push to main)

| Step | Action | Platform |
|------|--------|----------|
| 1 | Build Flutter web | GitHub Actions (Flutter 3.47.1) |
| 2 | Deploy static files | GitHub Pages |
| 3 | Apply DB migrations | Supabase CLI (manual) |
| 4 | Deploy Edge Functions | Supabase CLI (manual) |

### Deployment Architecture

```
┌─────────────────────────────────────────────────────────────┐
│  Developer pushes to main                                    │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  GitHub Actions (deploy.yml)                                 │
│  ├── Checkout code                                           │
│  ├── Install Flutter 3.47.1 (subosito/flutter-action)       │
│  ├── flutter pub get                                         │
│  ├── flutter build web --release --base-href /nexus-v2/     │
│  ├── Upload artifact (app/build/web/)                        │
│  └── Deploy to GitHub Pages                                  │
│                                                              │
│  Live URL: https://agni-eialarasu.github.io/nexus-v2/       │
│                                                              │
├─────────────────────────────────────────────────────────────┤
│  Supabase (manual via CLI after merge)                       │
│  ├── supabase db push          (apply migrations)           │
│  └── supabase functions deploy (deploy edge functions)      │
└─────────────────────────────────────────────────────────────┘
```

### Why GitHub Pages (not Vercel)?

Vercel's build environment has a locked Dart SDK (3.5.4) that cannot be overridden via custom scripts. GitHub Actions with `subosito/flutter-action` provides full control over the Flutter SDK version, ensuring consistent builds.

## Quality Gates per PR

Every feature PR must include:
- ✅ Unit tests for new models/utilities
- ✅ Widget tests for new UI components
- ✅ RLS policy tests for new/modified tables
- ✅ `flutter analyze` clean (zero warnings)
- ✅ `dart format` clean (consistent style)
- ✅ No hardcoded strings (i18n-ready)

## Local Development

```bash
# Start Supabase local
supabase start

# Run Flutter web
cd app && flutter run -d chrome

# Run code generation (after model changes)
cd app && dart run build_runner build --delete-conflicting-outputs

# Run tests
cd app && flutter test

# Run analyze
cd app && flutter analyze --fatal-infos

# Check formatting
cd app && dart format --set-exit-if-changed lib/ test/

# Apply new migration
supabase migration new <description>
# Edit the generated SQL file, then:
supabase db reset  # Resets local DB with all migrations + seed
```

## Supabase Deployment (Backend)

```bash
# Push database migrations to production
supabase db push --linked

# Deploy all Edge Functions
supabase functions deploy setup-tenant
supabase functions deploy switch-tenant

# Check migration status
supabase migration list --linked
```

## Environment Setup

| Environment | Flutter Web | Supabase |
|-------------|------------|----------|
| **Local** | `flutter run -d chrome` | `supabase start` (Docker) |
| **Staging** | GitHub Pages (auto on merge) | Supabase project (linked) |
| **Production** | TBD (custom domain) | Same Supabase project |

## Useful Commands

```bash
# View deployment status
# Go to: https://github.com/agni-eialarasu/nexus-v2/actions

# Manually trigger deploy
# Go to: Actions → "Deploy to GitHub Pages" → "Run workflow"

# View live site
# https://agni-eialarasu.github.io/nexus-v2/
```
