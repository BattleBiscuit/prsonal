---
name: Library
type: screen
status: approved
---

## Description
The exercise library (Exercises tab, route `/library`). A searchable list of exercises, each shown
as a [[library_exercise_card]], with a FAB to create and tap-to-edit / delete via the
[[library_exercise_form]].

## Layout

```
┌───────────────────────────────────────┐
│ PRsonal · Exercises                   │
│ [ Search exercises… ]                 │
├───────────────────────────────────────┤
│ Bench Press  [strength] Chest    🗑   │
│ Squat        [strength] Legs 🏆140 🗑 │
│                                  ( + ) │
└───────────────────────────────────────┘
```

## Widgets used

| Widget | Spec |
|--------|------|
| AppPageShell · AppFab · AppModal | shared |
| LibraryExerciseCard | `widgets/library_exercise_card.md` |
| LibraryExerciseForm | `widgets/library_exercise_form.md` |

## State dependencies
- `libraryListProvider` / `libraryServiceProvider` and a local search query

## Acceptance Criteria
- AC-001: Lists exercises, each with its type and primary muscles
- AC-002: Typing in the search filters the list
- AC-003: Tapping the FAB opens the exercise form to create a new exercise
- AC-004: Tapping a card opens the exercise form to edit it
- AC-005: Tapping delete confirms and then removes the exercise
- AC-006: Shows an empty state when the library is empty
