---
name: RoutineEdit
type: screen
status: approved
---

## Description
Create or edit a routine (routes `/routines/new` and `/routines/:id/edit`). A name field, a notes
field, and an ordered, reorderable list of exercises (each an [[exercise_list_item]]) edited via
the [[exercise_form]]. A Save FAB persists the routine; leaving with unsaved changes prompts a
discard confirmation. Edit mode adds a "Delete routine" action.

## Layout

```
┌───────────────────────────────────────┐
│ ← New Routine                         │
├───────────────────────────────────────┤
│ [ Routine name ]                      │
│ [ Notes ]                             │
│ EXERCISES                      + Add  │
│ ☰ Bench Press   3 sets · 10×80kg   🗑 │
│ ☰ Squat         3 sets · 8×100kg   🗑 │
│ ( delete routine — edit mode only )   │
│                              ( ✓ Save)│
└───────────────────────────────────────┘
```

## Widgets used

| Widget | Spec |
|--------|------|
| AppPageShell · AppInput · AppTextarea · AppFab · AppModal | shared |
| ExerciseListItem | `widgets/exercise_list_item.md` |
| ExerciseForm | `widgets/exercise_form.md` |

## State dependencies
- `routineDraftProvider(id?)` — the routine + its exercises for edit; null for create
- `routinesServiceProvider` — persistence
- `libraryOptionsProvider` — exercise options for the form picker

## Navigation
- Entered from: Routines list (+ New / card) · session-pick add sheet
- Navigates back to the previous screen on save / discard

## Acceptance Criteria
- AC-001: In create mode the name field starts empty; in edit mode it is populated from the routine
- AC-002: Tapping "Add" opens the exercise form
- AC-003: Tapping an exercise item opens the exercise form populated with its values
- AC-004: The exercise list is reorderable
- AC-005: Tapping Save persists the routine and navigates back
- AC-006: Saving with an empty name shows a validation error and does not persist
- AC-007: Attempting to leave with unsaved changes prompts a discard confirmation
