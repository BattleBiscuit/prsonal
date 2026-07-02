---
name: LibraryService
type: service
status: approved
---

## Description
CRUD and search over the exercise library ([[exercise]]), plus the best estimated 1RM per exercise
(read from logged PR sets) used to show a PR chip. Exposed via `libraryServiceProvider`. Because
routine/set exercise names are derived from the library, no rename cascade is needed.

View model: `LibraryExercise { id, name, type, primaryMuscles, secondaryMuscles, notes, bestOneRepMax }`.

## Methods

| Method | Inputs | Output | Side Effects |
|--------|--------|--------|--------------|
| watchExercises | — | `Stream<List<LibraryExercise>>` | none — alphabetical, with bestOneRepMax |
| searchExercises | `String query` | `Future<List<LibraryExercise>>` | none — case-insensitive name substring |
| createExercise | `{String name, ExerciseType type, List<Muscle> primaryMuscles, List<Muscle> secondaryMuscles, String? notes}` | `Future<String>` | inserts; returns id |
| updateExercise | `String id, {String? name, ExerciseType? type, List<Muscle>? primaryMuscles, List<Muscle>? secondaryMuscles, String? notes}` | `Future<void>` | updates fields |
| deleteExercise | `String id` | `Future<void>` | deletes the exercise; throws `ExerciseInUseException` while any routine still references it |

## Error Cases
- `deleteExercise` throws `ExerciseInUseException` if the exercise is still referenced by a
  `RoutineExercises` row (the caller must remove it from routines first) — the DB's own
  `onDelete: restrict` constraint surfaces as a raw `SqliteException`, which the service catches
  and rewraps into this typed exception. Past `workoutSets.exerciseId` references are exempt —
  sessions are immutable historical records that key display off the frozen `exerciseName`
  snapshot, not a live join, so a deleted exercise's history stays intact.

## Acceptance Criteria
- AC-001: createExercise inserts an exercise and returns its id
- AC-002: watchExercises emits exercises ordered alphabetically by name
- AC-003: updateExercise changes the exercise fields
- AC-004: deleteExercise removes the exercise
- AC-005: watchExercises includes the best estimated 1RM for each exercise that has logged PR sets
- AC-006: searchExercises filters by case-insensitive name substring
- AC-007: deleteExercise is rejected while the exercise is still referenced by a routine
