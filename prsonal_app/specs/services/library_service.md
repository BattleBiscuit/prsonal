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
| deleteExercise | `String id` | `Future<void>` | deletes the exercise |

## Acceptance Criteria
- AC-001: createExercise inserts an exercise and returns its id
- AC-002: watchExercises emits exercises ordered alphabetically by name
- AC-003: updateExercise changes the exercise fields
- AC-004: deleteExercise removes the exercise
- AC-005: watchExercises includes the best estimated 1RM for each exercise that has logged PR sets
- AC-006: searchExercises filters by case-insensitive name substring
