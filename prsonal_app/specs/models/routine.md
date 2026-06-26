---
name: Routine
type: model
status: approved
---

## Description
A reusable, named, ordered template of exercises (e.g. "Push Day A"). Backed by the Drift table
`routines`. A routine owns a list of RoutineExercise rows; it can be started directly or assigned
to days within a Plan. `updatedAt` is refreshed on every edit and drives the
recency sort on the Routines list.

## Fields

| Field | Type | Nullable | Default | Validation |
|-------|------|----------|---------|------------|
| id | String | no | uuid v4 | non-empty |
| name | String | no | — | non-empty after trim |
| notes | String? | yes | null | — |
| createdAt | DateTime | no | now | — |
| updatedAt | DateTime | no | now | refreshed on every mutation |

## Relationships
- Has many: RoutineExercise (via `routineId`, ordered by `position`)
- Referenced by: PlanEntry, WorkoutSession

## Acceptance Criteria
- AC-001: validateRoutineName returns false for an empty or whitespace-only name and true otherwise
- AC-002: exerciseCountLabel returns "1 exercise" for a count of one and "N exercises" for any other count
