# Nexus v2

**Multi-tenant Project Portfolio Management Platform**

Built with Flutter (Web) + Supabase.

🌐 **Live:** https://agni-eialarasu.github.io/nexus-v2/

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI | Flutter 3.47 (Web, responsive) |
| State | Riverpod 3 (code generation) |
| Routing | GoRouter |
| Backend | Supabase (Auth, PostgreSQL, Realtime, Edge Functions) |
| Multi-tenancy | Shared schema + RLS + JWT claims |
| Auth | Supabase Auth (email/password, Google OAuth) |
| RBAC | Role-based access control with view modes |
| Deployment | GitHub Pages (staging) + Vercel (production) + Supabase CLI (backend) |
| CI/CD | GitHub Actions (Flutter 3.47.1) |

## Repository Structure

```
nexus-v2/
├── app/                    # Flutter application
│   ├── lib/
│   │   ├── core/          # Theme, constants, shared widgets
│   │   ├── features/      # Feature-first modules
│   │   ├── models/        # Shared data models (freezed)
│   │   ├── providers/     # Global Riverpod providers
│   │   ├── repositories/  # Data access layer
│   │   └── routing/       # GoRouter configuration
│   ├── test/              # Unit + widget tests
│   ├── web/               # Web-specific assets
│   └── pubspec.yaml
├── supabase/
│   ├── migrations/        # SQL migrations (numbered)
│   ├── functions/         # Edge Functions (Deno/TypeScript)
│   ├── tests/             # RLS policy tests (pgTAP)
│   ├── seed.sql           # Development seed data
│   └── config.toml        # Supabase project config
├── docs/                  # Project documentation
├── .github/workflows/     # CI/CD pipelines
│   ├── ci.yml                   # PR checks (analyze, test, format)
│   ├── deploy-staging.yml       # main → GitHub Pages (staging)
│   └── deploy-production.yml    # prod → Vercel (production, inactive)
├── .kiro/steering/        # Kiro AI steering rules
└── README.md
```

## Getting Started

### Prerequisites

- Flutter SDK 3.47+ (`flutter --version`)
- Supabase CLI (`supabase --version`)
- Node.js 20+ (for Supabase Edge Functions local dev)

### Setup

```bash
# 1. Clone
git clone https://github.com/agni-eialarasu/nexus-v2.git
cd nexus-v2

# 2. Flutter dependencies
cd app && flutter pub get && cd ..

# 3. Supabase local dev
supabase start    # Starts local Supabase (Docker)
supabase db reset # Apply migrations + seed

# 4. Run Flutter web
cd app && flutter run -d chrome
```

### Environment Variables

Create `app/.env` (not committed):
```
SUPABASE_URL=http://localhost:54321
SUPABASE_ANON_KEY=<your-local-anon-key>
```

## CI/CD

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `ci.yml` | PR/push to `main` | Flutter analyze + test + format check |
| `deploy-staging.yml` | Push to `main` | Build Flutter web + deploy to GitHub Pages (staging) |
| `deploy-production.yml` | Push to `prod` | Build in Actions + deploy to Vercel (production) — **inactive until Vercel is set up** |

## Environments

| Environment | Branch | Platform | base-href |
|-------------|--------|----------|-----------|
| Staging | `main` | GitHub Pages | `/nexus-v2/` |
| Production | `prod` | Vercel | `/` |

Config is compiled in via `--dart-define` (`APP_ENV`, `SUPABASE_URL`, `SUPABASE_ANON_KEY`);
see [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md#2-environment-setup).

## Development Workflow

- **Branching:** `sprint/N` or `feat/` branches → PR to `main` (never push to `main` directly)
- **CI:** Flutter analyze + test + format on every PR
- **Deploy:** merge to `main` → staging (GitHub Pages); promote `main` → `prod` → production (Vercel)
- **Backend:** Supabase migrations + Edge Functions via CLI

See [docs/DEVELOPMENT.md](docs/DEVELOPMENT.md) for the full guide and
[CONTRIBUTING.md](CONTRIBUTING.md) for onboarding.

## License

Proprietary — All rights reserved.
