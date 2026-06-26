---
name: LibraryExerciseForm
type: widget
status: approved
---

## Description
The create/edit exercise form, ported from gym-app's `LibraryExerciseForm`. A name field, a
strength/cardio type toggle, selectable primary and secondary muscle chips (the seven muscles),
and a notes field. Presented inside an [[app_modal]].

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| initial | LibraryExerciseData? | no | null | Existing exercise to edit; null = create |
| onSubmit | void Function(LibraryExerciseData) | yes | — | Called with the validated data |
| onCancel | VoidCallback | yes | — | Dismiss without saving |

`LibraryExerciseData { id?, name, type, primaryMuscles, secondaryMuscles, notes }`.

## Acceptance Criteria
- AC-001: Widget renders a name field and a strength/cardio type toggle
- AC-002: Widget renders selectable primary and secondary muscle chips
- AC-003: Submitting with an empty name shows a validation error and does not call onSubmit
- AC-004: Submitting a valid form calls onSubmit with the selected type and muscles
