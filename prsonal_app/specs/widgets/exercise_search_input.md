---
name: ExerciseSearchInput
type: widget
status: approved
---

## Description
A select-style field that opens a bottom-sheet picker to search the exercise library and choose an
exercise, ported from gym-app's `ExerciseSearchInput`. When the query matches no existing exercise
it offers a "Create" option that creates a new library entry. Used inside the [[exercise_form]].

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| selectedName | String? | no | null | Currently selected exercise name |
| exercises | List\<ExerciseOption\> | yes | — | Library options to search |
| onSelected | void Function(ExerciseOption) | yes | — | Called when an option is chosen |
| onCreate | void Function(String name)? | no | null | Called to create a new exercise from the query |
| errorText | String? | no | null | Validation error shown on the field |

`ExerciseOption { id, name, type, primaryMuscles }`; the list shows "strength · Chest, Shoulders".

## Visual States

| State | Appearance |
|-------|------------|
| empty | placeholder "Select exercise" (text-3), chevron-down |
| selected | selectedName in text-1 |
| error | danger border + errorText below |
| sheet open | search field + filtered list + optional "Create" row |

## Acceptance Criteria
- AC-001: Widget renders the selected exercise name, or a placeholder when none is selected
- AC-002: Tapping the field opens a search sheet listing the exercises
- AC-003: Typing in the search filters the listed exercises
- AC-004: Selecting an exercise calls onSelected and closes the sheet
- AC-005: When the query matches no exercise a "Create" option is shown and calls onCreate with the query
