---
name: WorkoutSet
type: model
status: approved
---

## Description
One logged set within a workout session. Backed by the Drift table `workoutSets`. Holds both the
planned target (copied from the RoutineExercise when the session starts) and the actual logged
values. `exerciseName` is **snapshotted** for historical integrity; `exerciseId` is an optional
back-link used for analytics joins. At completion the service freezes `effectiveWeight` and
`estimated1RM` and sets `isPR` (see [[workout_math]] and the session service).

Compared with gym-app, the denormalised `startedAt` and `muscleGroups` columns are **removed** —
the session start time is joined from `workoutSessions` and muscles from `exercises`.

## Fields

| Field | Type | Nullable | Default | Meaning |
|-------|------|----------|---------|---------|
| id | String | no | uuid v4 | identifier |
| sessionId | String | no | — | FK → workoutSessions.id |
| exercisePosition | int | no | — | exercise order within the session |
| exerciseId | String? | yes | null | FK → exercises.id (analytics back-link) |
| exerciseName | String | no | — | snapshot of the exercise name |
| setIndex | int | no | — | 0-based index within the exercise |
| type | ExerciseType | no | strength | strength vs cardio |
| plannedReps | int? | yes | null | target reps (strength) |
| plannedWeight | double? | yes | null | target kg (strength) |
| isBodyweight | bool | no | false | load relative to bodyweight |
| actualReps | int? | yes | null | logged reps |
| actualWeight | double? | yes | null | logged kg |
| effectiveWeight | double? | yes | null | frozen bodyweight-resolved load; null for cardio |
| plannedDuration | int? | yes | null | target minutes (cardio) |
| plannedLevel | int? | yes | null | target level (cardio) |
| actualDuration | int? | yes | null | logged minutes (cardio) |
| actualLevel | int? | yes | null | logged level (cardio) |
| restSeconds | int | no | 0 | rest after this set |
| completedAt | DateTime? | yes | null | when logged; null = not done |
| skipped | bool | no | false | user skipped without logging |
| isPR | bool | no | false | set a new personal record |
| estimated1RM | double? | yes | null | frozen Epley 1RM; null for cardio |

## Relationships
- Belongs to: WorkoutSession (via `sessionId`)
- References: Exercise (via `exerciseId`, optional)

## Acceptance Criteria
- AC-001: workoutSetIsComplete is true when the set has a completedAt and is not skipped
- AC-002: workoutSetIsComplete is false when the set is skipped even if completedAt is set
- AC-003: formatStrengthSet renders reps and weight as "10×80kg"
- AC-004: formatStrengthSet renders a bodyweight set as "10×BW+10kg"
- AC-005: formatCardioSet renders duration and level as "30min · lvl5"
- AC-006: setEstimatedOneRepMax returns null for a cardio set and the Epley 1RM for a completed strength set
