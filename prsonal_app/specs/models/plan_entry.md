---
name: PlanEntry
type: model
status: approved
---

## Description
One slot in a Plan: a routine assigned to an optional day of the week. Backed by the Drift table
`planEntries`. A plan may have multiple entries on the same day, and an entry may be unscheduled
(`dayOfWeek == null`). The routine's display name is **derived by joining `routines`** — it is
not stored on the entry (a simplification over gym-app, which kept a stale snapshot).

Days are zero-indexed Monday-first: 0 = Monday … 6 = Sunday.

## Fields

| Field | Type | Nullable | Default | Validation |
|-------|------|----------|---------|------------|
| id | String | no | uuid v4 | non-empty |
| planId | String | no | — | FK → plans.id |
| routineId | String | no | — | FK → routines.id |
| dayOfWeek | int? | yes | null | null or 0–6 |
| order | int | no | append index | ≥ 0 |

## Relationships
- Belongs to: Plan (via `planId`)
- References: Routine (via `routineId`)

## Acceptance Criteria
- AC-001: dayOfWeekLabel returns the three-letter weekday for 0–6 as Mon, Tue, Wed, Thu, Fri, Sat, Sun
- AC-002: dayOfWeekLabel returns "·" when dayOfWeek is null (unscheduled)
- AC-003: validateDayOfWeek accepts null and integers 0 through 6 and rejects any value outside that range
