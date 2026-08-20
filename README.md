# Nexus v2

**Multi-tenant Project Portfolio Management Platform**

Built with Flutter (Web) + Supabase.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| UI | Flutter 3.x (Web, responsive) |
| State | Riverpod 3 (code generation) |
| Routing | GoRouter |
| Backend | Supabase (Auth, PostgreSQL, Realtime, Edge Functions) |
| Multi-tenancy | Shared schema + RLS + JWT claims |
| Auth | Supabase Auth (email/password, Google OAuth) |
| RBAC | Role-based access control with view modes |
| Deployment | Vercel (web) + Supabase CLI (backend) |

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
├── .kiro/steering/        # Kiro AI steering rules
└── README.md
```

## Getting Started

### Prerequisites

- Flutter SDK 3.x (`flutter --version`)
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

## Development Workflow

- **Branching:** `sprint/N` branches → PR to `main`
- **CI:** Flutter analyze + test + Supabase migration check on every PR
- **Deploy:** Merge to `main` → auto-deploy staging
- **Release:** Tag-based production promotion

See [docs/dev-workflow.md](docs/dev-workflow.md) for full protocol.

## License

Proprietary — All rights reserved.
