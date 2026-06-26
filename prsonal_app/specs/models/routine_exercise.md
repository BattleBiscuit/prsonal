---
name: RoutineExercise
type: model
status: approved
---

## Description
An exercise slot within a routine: a link to a library Exercise, its position in the routine, and
its planned sets. Backed by the Drift table `routineExercises`. The planned sets are stored as a
JSON list of **SetTarget** value objects in a single column (`sets`). The exercise's display name
and type are **derived from the linked Exercise** (not snapshotted), so renaming an exercise in
the library updates every routine automatically; therefore `exerciseId` is required.

### Embedded value object: SetTarget
A planned target for one set. `kind` mirrors the exercise's `ExerciseType`.

| Field | Type | Default (strength) | Default (cardio) | Meaning |
|-------|------|--------------------|------------------|---------|
| kind | ExerciseType | strength | cardio | strength vs cardio |
| reps | int | 10 | — | planned reps (strength) |
| weight | double | 0 | — | planned kg; 0 = bodyweight baseline (strength) |
| isBodyweight | bool | false | false | load is relative to bodyweight |
| duration | int? | null | 20 | planned minutes (cardio) |
| level | int? | null | 1 | planned machine level (cardio) |
| restSeconds | int | 90 | 0 | rest after this set |

## Fields

| Field | Type | Nullable | Default | Validation |
|-------|------|----------|---------|------------|
| id | String | no | uuid v4 | non-empty |
| routineId | String | no | — | FK → routines.id |
| exerciseId | String | no | — | FK → exercises.id |
| position | int | no | append index | ≥ 0 |
| notes | String? | yes | null | — |
| sets | List\<SetTarget\> | no | one default set | at least one set |

## Relationships
- Belongs to: Routine (via `routineId`)
- References: Exercise (via `exerciseId`)

## Acceptance Criteria
- AC-001: SetTarget.strength() defaults to 10 reps, 0 kg, not bodyweight, and 90 seconds rest
- AC-002: SetTarget.cardio() defaults to 20 minutes duration, level 1, and 0 seconds rest
- AC-003: a strength SetTarget round-trips through JSON preserving reps, weight, isBodyweight and restSeconds
- AC-004: a cardio SetTarget round-trips through JSON preserving duration, level and restSeconds
- AC-005: SetTarget.isCardio is true only when kind is cardio
- AC-006: validateSets returns false for an empty list and true when at least one set is present
