# Sprint Backlog

Candidate work grouped into **epics**, not yet scheduled into sprints. Items
graduate from here into a numbered sprint in the [Sprint Tracker](sprint-tracker.md)
when picked up. For the *why/what* behind these, see
[product-scope.md](product-scope.md); for the *how*, see [architecture.md](architecture.md).

> **⚠️ Provisional — pending BA.** The MVP scope and the first feature are **not
> yet decided**. The epics below are a **strawman** built from the v1
> (React/NestJS) feature set: a structured candidate pool to react to in the
> stakeholder meeting, not committed scope. Nothing here is checked, because no
> feature work has started. Epic **ordering reflects a suggested build sequence**
> (foundation first), but sequencing is the BA/stakeholder's call.
>
> Each epic carries a **Goal**, **candidate items**, and **Open Questions /
> Expectations** — the specific things the BA needs to clarify before the epic
> can be scoped into sprints.

---

## How to use this doc

1. The BA brings the **first feature** (from v1). Record it under
   [First Feature](#first-feature-from-ba) and answer that epic's open questions.
2. Promote the concrete slice into a numbered sprint in the
   [Sprint Tracker](sprint-tracker.md); mark the item here with the sprint number.
3. Keep entries small and outcome-focused. Resolve open questions inline (strike
   through or annotate with the decision) rather than deleting them, so the
   rationale stays visible.

---

## Table of Contents

- [First Feature (from BA)](#first-feature-from-ba)
- [Epic 0 — Foundation](#epic-0--foundation)
- [Epic 1 — Work Management](#epic-1--work-management)
- [Epic 2 — Strategy & Outcomes](#epic-2--strategy--outcomes)
- [Epic 3 — Resource & Financials](#epic-3--resource--financials)
- [Epic 4 — People & Org](#epic-4--people--org)
- [Epic 5 — Collaboration & Platform](#epic-5--collaboration--platform)
- [Cross-Cutting Open Decisions](#cross-cutting-open-decisions)

---

## First Feature (from BA)

> _Placeholder._ The first concrete feature the BA prioritizes from v1 lands
> here, then graduates into a numbered sprint in the tracker.

- [ ] _TBD — awaiting BA._

---

## Epic 0 — Foundation

> **Goal:** the tenant-aware shell every feature sits on — auth, RBAC, routing,
> and the app scaffold — so the first feature drops onto a real skeleton rather
> than a bare login screen.

**Status:** partially started. Backend has schema + RLS + tenant Edge Functions
(`setup-tenant`, `switch-tenant`); the Flutter side is still a scaffold (bare
`LoginScreen`, stack deps not yet added). See [session-handoff.md](session-handoff.md).

**Candidate items**
- [ ] Add the stack deps (`flutter_riverpod` + `riverpod_annotation`/generator, `go_router`, `supabase_flutter`, `freezed`/`json_serializable`, `mocktail`) and the `models/`/`providers/`/`repositories/`/`routing/` skeleton.
- [ ] Wire `ProviderScope` + Supabase client provider from `Env` (`core/config/env.dart`).
- [ ] Supabase Auth flow in the UI (email/password + Google OAuth) replacing the placeholder login.
- [ ] Tenant-scoped `GoRouter` (`/org/:slug/...`) + app shell (responsive nav at all 3 breakpoints).
- [ ] RBAC resolution (`isOrgAdmin > TenantRole > User overrides`) gating routes + sidebar items.
- [ ] Tenant switching wired to the `switch-tenant` Edge Function.

**Open Questions / Expectations**
- What auth methods are in the MVP — email/password only, or Google OAuth too?
- Is multi-tenant switching in the MVP, or single-tenant per user for v1 parity?
- Does the v1 permission model map 1:1 to the page/action/view-mode RBAC, or does it need remodeling?
- Onboarding: self-serve tenant signup (join code exists in schema) vs. admin-provisioned only?

---

## Epic 1 — Work Management

> **Goal:** the core delivery objects — the day-to-day surface most users live in.

**Candidate items** (carried from v1)
- [ ] **Projects** — CRUD, members, milestones.
- [ ] **Portfolios** — group projects, strategic alignment.
- [ ] **RAID** — risks, assumptions, issues, dependencies.
- [ ] **Roadmaps** — timeline view.

**Open Questions / Expectations**
- Which of these is the **first feature**? (Projects is the likely anchor — most others reference it.)
- Projects: what's the minimum viable field set + lifecycle/status model from v1?
- Portfolios: is strategic-alignment scoring in the MVP or deferred to v2?
- Roadmaps: is this a distinct feature or a view over Projects/milestones?
- What entities need `tenant_id` + RLS + RLS tests added (every table, per steering rules)?

---

## Epic 2 — Strategy & Outcomes

> **Goal:** connect execution to intent — objectives and the dashboards that
> report on them.

**Candidate items** (carried from v1)
- [ ] **OKRs** — objectives, key results, contributions.
- [ ] **Dashboards** — executive + standard views.

**Open Questions / Expectations**
- Do OKRs link to Projects/Portfolios (contributions), and is that linkage in the MVP?
- Dashboards: which metrics/widgets are must-have vs. nice-to-have for the first cut?
- Executive vs. standard dashboard — one configurable surface or two distinct screens?
- View modes (own/team/global) — how do they interact with dashboard data scoping?

---

## Epic 3 — Resource & Financials

> **Goal:** the planning and money layer — capacity, budgets, and time.

**Candidate items** (carried from v1)
- [ ] **Capacity Planning** — resources, allocation.
- [ ] **Financials** — budgets, actuals, forecasts.
- [ ] **Timesheets** — time tracking.

**Open Questions / Expectations**
- Is any of this in the MVP, or is it a later phase? (Often deferred past initial launch.)
- Financials: what currency/rounding/rollup rules from v1 must be preserved?
- Capacity: does it depend on Team Management (Epic 4) being built first?
- Timesheets: approval workflow in scope, or raw entry only for MVP?

---

## Epic 4 — People & Org

> **Goal:** who's in the system and how the organization is modeled.

**Candidate items** (carried from v1)
- [ ] **Team Management** — users, roles, org chart.
- [ ] **Beacon** — business capability model.

**Open Questions / Expectations**
- Team Management overlaps Epic 0's RBAC — where's the boundary (identity/RBAC vs. org-chart/profile management)?
- Is Beacon (capability model) core to the MVP or a specialized later module?
- Org chart: hierarchical `manager_id` (already in schema) sufficient, or richer structures needed?

---

## Epic 5 — Collaboration & Platform

> **Goal:** cross-cutting collaboration and external connectivity that layer over
> the domain features.

**Candidate items** (carried from v1)
- [ ] **Discussions** — collaboration / comments.
- [ ] **Notifications** — realtime alerts (Supabase Realtime).
- [ ] **Templates** — project templates.
- [ ] **Integrations** — Jira, Confluence.

**Open Questions / Expectations**
- Notifications: which events trigger them, and are they in the MVP or a fast-follow?
- Discussions: standalone feature or comment threads attached to domain objects (Projects, RAID, ...)?
- Integrations: are Jira/Confluence MVP-critical, or post-launch? Which direction (import, sync, two-way)?
- Templates: which entities are templatable (Projects only, or Portfolios/OKRs too)?

---

## Cross-Cutting Open Decisions

Carried forward from the v1 project plan — these gate scoping across all epics
and are the core agenda for the stakeholder meeting:

- **MVP feature scope** — which epics/features are in the first release vs. deferred.
- **First feature** — the specific v1 feature the BA prioritizes to start.
- **Timeline** — target for MVP.
- **Data migration from v1** — is existing v1 data migrated, and if so, which entities?
- **Integration priorities** — Jira/Confluence and any others, and their sequencing.
- **Features to drop from v1** — anything explicitly not carried forward.

> These are also tracked as "Open Decisions" in [product-scope.md](product-scope.md);
> resolve them in one place (there) and reference the outcome here.
