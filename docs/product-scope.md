# Product Scope — Nexus v2

The *what* and *why* of Nexus v2. For the *how*, see [architecture.md](architecture.md).
For status and sprints, see [sprint-tracker.md](sprint-tracker.md).

> **Status: draft skeleton.** MVP scope is pending the first feature definition
> from the BA (derived from the v1 repo). Sections below are structure to fill
> in as scope firms up — most are intentionally TBD.

---

## 1. Vision

Nexus v2 is a **multi-tenant Project Portfolio Management (PPM) platform** — a
greenfield rebuild of the existing v1 (React/NestJS) product on Flutter Web +
Supabase. It gives organizations a single place to plan, track, and report on
projects, portfolios, and the resources behind them.

## 2. Users & Roles

Access is governed by RBAC with view modes (own / team / global) and a
precedence of `isOrgAdmin > TenantRole > User overrides`.

| Role | Description | TBD |
| :-- | :-- | :-- |
| Org Admin | Full control within a tenant | scope details TBD |
| Tenant Role(s) | Named roles with page/action/view-mode permissions | catalog TBD |
| User | Base access + individual overrides | TBD |

## 3. MVP Scope (pending BA)

The first feature and MVP cut are **not yet decided**. Candidate capabilities
are carried from v1 (see [project-plan.md](project-plan.md) backlog): Dashboard,
Projects, Portfolios, OKRs, Financials, Capacity, RAID, Roadmaps, Timesheets,
Team Management, Beacon, Discussions, Notifications, Templates, Integrations.

- **In MVP:** _TBD from stakeholder meeting._
- **Deferred:** _TBD._
- **Dropped from v1:** _TBD._

## 4. Success Criteria

_TBD_ — define measurable outcomes (adoption, key workflows completed, etc.)
once MVP scope is set.

## 5. Non-Goals

_TBD_ — record explicitly what v2 will not do, to keep scope honest.

## 6. Open Decisions

- MVP feature scope (first feature from BA).
- Timeline.
- Data migration from v1 (if any).
- Integration priorities (Jira, Confluence, ...).
