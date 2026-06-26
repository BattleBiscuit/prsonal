---
name: WorkoutSession
type: model
status: approved
---

## Description
A performed (or in-progress) workout. Backed by the Drift table `workoutSessions`. Created when
the user starts a routine and finalised when they finish it. Sessions are immutable historical
records, so `routineName` is **snapshotted** at start (it must survive the source routine being
edited or deleted). Total volume is **not stored** — it is computed on demand from the session's
sets (a simplification over gym-app's stored-and-recomputed dual path).

A session is shown as **"Abandoned"** in history when it is completed but logged zero volume;
there is no separate stored status for it.

## Fields

| Field | Type | Nullable | Default | Validation |
|-------|------|----------|---------|------------|
| id | String | no | uuid v4 | non-empty |
| routineId | String | no | — | FK → routines.id |
| routineName | String | no | — | snapshot at start |
| startedAt | DateTime | no | now | — |
| completedAt | DateTime? | yes | null | set on finish |
| status | SessionStatus | no | active | one of `active`, `completed` |
| planId | String? | yes | null | FK → plans.id |
| planEntryId | String? | yes | null | FK → planEntries.id |

`SessionStatus { active, completed }`.

## Relationships
- Has many: WorkoutSet (via `sessionId`)
- References: Routine, Plan, PlanEntry

## Acceptance Criteria
- AC-001: SessionStatus resolves to and from its stored name (`active`, `completed`); an unknown name throws
- AC-002: defaultSessionStatus is active (a newly started session is active)
- AC-003: sessionIsAbandoned is true when the session is completed and its total volume is zero
- AC-004: sessionIsAbandoned is false for a completed session with positive volume
- AC-005: formatSessionDuration returns whole minutes under an hour (e.g. "47m") and "Hh Mm" at or above an hour
- AC-006: formatSessionDuration returns "—" when the session has no completedAt
