---
name: PlanEdit
type: screen
status: approved
---

## Description
Create or edit a training plan (routes `/plans/new`, `/plans/:id/edit`). A name field and a list of
entries, each mapping a routine to a day of the week via a [[day_of_week_selector]]. Routines are
added from a picker sheet. Saving replaces the plan's entries wholesale (matching gym-app). Edit
mode adds a "Delete plan" action.

## Layout

```
┌───────────────────────────────────────┐
│ ← New Plan                            │
├───────────────────────────────────────┤
│ [ Plan name ]                         │
│ WORKOUTS                       + Add  │
│ [Mon][Tue][Wed][Thu][Fri][Sat][Sun]   │
│   Push Day A                       🗑 │
│ ( delete plan — edit mode only )      │
│                              ( ✓ Save)│
└───────────────────────────────────────┘
```

## Widgets used

| Widget | Spec |
|--------|------|
| AppPageShell · AppInput · AppFab · AppModal | shared |
| DayOfWeekSelector | `widgets/day_of_week_selector.md` |

## State dependencies
- `planDraftProvider(id?)` — plan + entries for edit; null for create
- `plansServiceProvider` — persistence
- `routinesListProvider` — routine options for the picker

## Navigation
- Entered from: session-pick add sheet · plan pencil
- Navigates back on save / delete

## Acceptance Criteria
- AC-001: In create mode the name field is empty; in edit mode it is populated from the plan
- AC-002: Tapping "Add" opens a routine picker and selecting a routine adds an entry
- AC-003: Each entry exposes a day selector to assign its day of the week
- AC-004: Removing an entry removes it from the list
- AC-005: Tapping Save persists the plan name and entries and navigates back
- AC-006: Saving with an empty name shows a validation error and does not persist
- AC-007: In edit mode, deleting the plan removes it and navigates back
