---
name: Plan
type: model
status: approved
---

## Description
A weekly training plan: a named, ordered collection of PlanEntry rows that assign routines to
days of the week. Backed by the Drift table `plans`. Active plans drive the grouped "Planned"
sections on the Workout (session-pick) screen and the plan-adherence/streak analytics.

## Fields

| Field | Type | Nullable | Default | Validation |
|-------|------|----------|---------|------------|
| id | String | no | uuid v4 | non-empty |
| name | String | no | — | non-empty after trim |
| status | PlanStatus | no | active | one of `active`, `archived` |
| order | int | no | append index | ≥ 0 |
| createdAt | DateTime | no | now | — |

`PlanStatus { active, archived }`.

## Relationships
- Has many: PlanEntry (via `planId`, ordered by `order`)

## Acceptance Criteria
- AC-001: PlanStatus resolves to and from its stored name (`active`, `archived`); an unknown name throws
- AC-002: validatePlanName returns false for an empty or whitespace-only name and true otherwise
- AC-003: defaultPlanStatus is active (a newly created plan is active)
