---
name: Exercise
type: model
status: approved
---

## Description
An entry in the user's exercise library — the catalogue of movements that routines and logged
sets reference. Backed by the Drift table `exercises`. Exercises are either `strength`
(reps × weight) or `cardio` (duration × level) and are tagged with the muscles they train, used
by the muscle-balance radar on Progress.

## Fields

| Field | Type | Nullable | Default | Validation |
|-------|------|----------|---------|------------|
| id | String | no | uuid v4 | non-empty |
| name | String | no | — | non-empty after trim |
| type | ExerciseType | no | strength | one of `strength`, `cardio` |
| primaryMuscles | List\<Muscle\> | no | `[]` | ordered, deduplicated |
| secondaryMuscles | List\<Muscle\> | no | `[]` | ordered, deduplicated |
| notes | String? | yes | null | — |
| createdAt | DateTime | no | now | — |

`ExerciseType { strength, cardio }`. `Muscle` is a fixed seven-value enum in display order:
Chest, Shoulders, Arms, Back, Core, Legs, Glutes. Muscle lists are stored as JSON string arrays
of enum names via a Drift `TypeConverter`.

## Relationships
- Has many: RoutineExercise (via `exerciseId`)
- Has many: WorkoutSet (via `exerciseId`, optional back-link)

## Acceptance Criteria
- AC-001: ExerciseType resolves to and from its stored name (`strength`, `cardio`); an unknown name throws
- AC-002: Muscle exposes exactly seven values in the fixed order Chest, Shoulders, Arms, Back, Core, Legs, Glutes
- AC-003: Muscle.label returns the human-readable capitalised name
- AC-004: validateExerciseName returns false for an empty or whitespace-only name and true otherwise
- AC-005: primaryMuscles and secondaryMuscles preserve insertion order when round-tripped through JSON
