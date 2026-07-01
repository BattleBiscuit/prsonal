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
| ExerciseForm | `widgets/exercise_form.md` |

The exercise list itself is a plain `ListTile` per row (no dedicated
`ExerciseListItem` component — retired along with `RoutineCard` when the
routines list was folded into the flat Workout-tab redesign).

## State dependencies
- `routineDraftProvider(id?)` — the routine + its exercises for edit; null for create
- `routinesServiceProvider` — persistence
- `libraryOptionsProvider` — exercise options for the form picker

## Navigation
- Entered from: session-pick add sheet (+ New routine) · session-pick (tapping a routine name)
- Navigates back to the previous screen (Workout home) on save / discard

## Acceptance Criteria
- AC-001: In create mode the name field starts empty; in edit mode it is populated from the routine
- AC-002: Tapping "Add" opens the exercise form
- AC-003: Tapping an exercise item opens the exercise form populated with its values
- AC-004: The exercise list is reorderable
- AC-005: Tapping Save persists the routine and navigates back
- AC-006: Saving with an empty name shows a validation error and does not persist
- AC-007: Attempting to leave with unsaved changes prompts a discard confirmation
- AC-008: The "Delete routine" action is shown in edit mode only — hidden in create mode
- AC-009: Tapping "Delete routine" shows a delete confirmation; confirming deletes the routine and navigates back to Workout home without persisting other pending edits
- AC-010: Each exercise row carries a trailing edit affordance icon distinct from the drag handle
  (design_system.md Tier 1: a `drag_handle` alone communicates "reorder," not "tap to edit," so the
  row's own `onTap` needs its own glyph)
