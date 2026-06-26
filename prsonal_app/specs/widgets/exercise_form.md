---
name: ExerciseForm
type: widget
status: approved
---

## Description
The exercise editor, ported from gym-app's `ExerciseForm`. Used both in the routine editor (add /
edit an exercise) and on the active-session screen (add an exercise mid-workout). It hosts an
[[exercise_search_input]] to pick/create the library exercise, a type-aware set table (strength:
reps · BW · weight · rest; cardio: minutes · level · rest), an add/remove-set control, and a notes
field. Presented inside an [[app_modal]].

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| initial | ExerciseFormData? | no | null | Existing exercise to edit; null = new with one default set |
| exercises | List\<ExerciseOption\> | yes | — | Library options for the picker |
| onSubmit | void Function(ExerciseFormData) | yes | — | Called with the validated form data |
| onCancel | VoidCallback | yes | — | Dismiss without saving |
| onCreateExercise | void Function(String name)? | no | null | Create a new library exercise from the picker |

`ExerciseFormData { String? exerciseId, String? exerciseName, ExerciseType type, String? notes, List<SetTarget> sets }`.

## Visual States

| State | Appearance |
|-------|------------|
| strength | set rows: # · reps · BW toggle · weight · rest · ✕ |
| cardio | set rows: # · minutes · level · rest · ✕ |
| validation | picker shows an error when no exercise is selected on submit |

## Acceptance Criteria
- AC-001: Widget renders an exercise picker and at least one set row
- AC-002: Adding a set appends a new set row
- AC-003: Removing a set removes it; the remove control is disabled when only one set remains
- AC-004: Toggling bodyweight on a strength set marks that set as bodyweight
- AC-005: Submitting with no exercise selected shows a validation error and does not call onSubmit
- AC-006: Submitting a valid form calls onSubmit with the configured sets
