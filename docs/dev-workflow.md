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
main (protected) ─── auto-deploys to staging
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

## CI Pipeline (on every PR)

1. `flutter analyze` — zero warnings required
2. `flutter test` — all tests must pass
3. `dart format --set-exit-if-changed` — consistent formatting
4. Supabase migration validation

## Quality Gates per PR

Every feature PR must include:
- ✅ Unit tests for new models/utilities
- ✅ Widget tests for new UI components
- ✅ RLS policy tests for new/modified tables
- ✅ `flutter analyze` clean
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

# Apply new migration
supabase migration new <description>
# Edit the generated SQL file, then:
supabase db reset  # Resets local DB with all migrations + seed
```

## Deployment

| Target | Trigger | Platform |
|--------|---------|----------|
| Staging | Merge to main | Vercel (auto) |
| DB Migrations | Merge to main | Supabase CLI (manual or CI) |
| Edge Functions | Merge to main | Supabase CLI deploy |
| Production | Release tag | Manual promotion |
