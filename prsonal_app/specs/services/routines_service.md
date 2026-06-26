---
name: RoutinesService
type: service
status: approved
---

## Description
CRUD and ordering for routines and their exercises. Wraps the Drift DAOs for [[routine]] and
[[routine_exercise]] and exposes reactive lists via `routinesServiceProvider`. Exercise display
names are resolved by joining [[exercise]] (not stored), so no rename cascade is needed.

## Methods

| Method | Inputs | Output | Side Effects |
|--------|--------|--------|--------------|
| watchRoutines | — | `Stream<List<RoutineSummary>>` | none — ordered by updatedAt desc, includes exerciseCount |
| getRoutineForEdit | `String id` | `Future<RoutineDraft>` | none — routine + exercises (names resolved) in position order |
| createRoutine | `{String name, String? notes}` | `Future<String>` | inserts a routine; returns id |
| updateRoutine | `String id, {String? name, String? notes}` | `Future<void>` | updates fields; refreshes updatedAt |
| deleteRoutine | `String id` | `Future<void>` | deletes routine and its exercises |
| addExercise | `String routineId, {String exerciseId, List<SetTarget> sets, String? notes}` | `Future<void>` | appends at next position; touches routine updatedAt |
| updateExercise | `String id, {List<SetTarget>? sets, String? notes}` | `Future<void>` | updates an exercise |
| removeExercise | `String id` | `Future<void>` | deletes and renumbers remaining positions |
| reorderExercises | `String routineId, List<String> orderedIds` | `Future<void>` | persists new positions |

## Error Cases
- `getRoutineForEdit` throws `NotFoundException` when the routine id does not exist.

## Acceptance Criteria
- AC-001: createRoutine inserts a routine and returns its id
- AC-002: watchRoutines emits routines ordered most-recently-updated first, each with its exercise count
- AC-003: updateRoutine changes the fields and refreshes updatedAt
- AC-004: deleteRoutine removes the routine and all of its exercises
- AC-005: addExercise appends an exercise at the next position with its planned sets
- AC-006: removeExercise deletes the exercise and renumbers the remaining positions to be contiguous
- AC-007: reorderExercises persists the new positions
- AC-008: getRoutineForEdit returns the routine with its exercises resolved by library name in position order
