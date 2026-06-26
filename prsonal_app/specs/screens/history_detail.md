---
name: HistoryDetail
type: screen
status: approved
---

## Description
The full breakdown of a single completed workout (route `/history/:id`). Shows a summary header, a
PR banner listing any personal records, and a per-exercise set table of planned vs actual values.
An Edit toggle makes the actuals editable; Save persists the changes.

## Layout

```
┌───────────────────────────────────────┐
│ ← PRsonal · Workout Detail     Edit   │
├───────────────────────────────────────┤
│ WorkoutSummaryHeader                  │
│ 🏆 PRs this session: [Bench Press]    │
│ HistorySetTable (Bench Press)         │
│ HistorySetTable (Squat)               │
│                          ( ✓ Save )   │  Save FAB in edit mode
└───────────────────────────────────────┘
```

## Widgets used

| Widget | Spec |
|--------|------|
| AppPageShell · AppFab · AppBadge | shared |
| WorkoutSummaryHeader | `widgets/workout_summary_header.md` |
| HistorySetTable | `widgets/history_set_table.md` |

## State dependencies
- `historyDetailProvider(id)` / `historyServiceProvider` — the SessionDetail and edits

## Navigation
- Entered from: History list · Progress history preview
- Back: returns to the previous screen

## Acceptance Criteria
- AC-001: Shows the workout summary (routine, date, duration, volume, status)
- AC-002: Shows a per-exercise set table of planned and actual values
- AC-003: Shows a PR banner listing exercises that set a personal record
- AC-004: Tapping Edit makes the actual values editable
- AC-005: Saving edits persists the changes and exits edit mode
- AC-006: A skipped set is shown distinctly
