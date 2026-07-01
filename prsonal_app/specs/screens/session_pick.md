---
name: SessionPick
type: screen
status: implemented
---

## Description
The app's home screen (Workout tab, route `/`). A launch pad for starting a workout: it lists each
active plan as a block of day-assigned routine entries, plus an "Unplanned" block of routines not
in any active plan. Each routine has a one-tap start button. (When a session is already active the
router redirects here straight to `session-active`, so no resume banner is shown on this screen.)

## Layout

```
┌───────────────────────────────────────┐
│ PRsonal · Workout                     │  header
├───────────────────────────────────────┤
│ ┌ PUSH/PULL/LEGS            🔥3   ✎ ┐ │  plan block header
│ │ Mon   Push Day A          ✓   ▶  │ │  entry row (done this week)
│ │ Wed   Pull Day            ·   ▶  │ │  entry row
│ └───────────────────────────────────┘ │
│ ┌ Unplanned ──────────────────────── ┐ │
│ │ ·     Mobility            ·   ▶  │ │
│ └───────────────────────────────────┘ │
│                              ( + Add ) │  FAB → add sheet
└───────────────────────────────────────┘
```

## Widgets used

| Widget | Spec | Usage |
|--------|------|-------|
| AppPageShell | `widgets/app_page_shell.md` | header = "Workout" |
| PlanEntryRow | `widgets/plan_entry_row.md` | one per plan entry and per unplanned routine |
| AppFab | `widgets/app_fab.md` | "Add" |
| AppModal | `widgets/app_modal.md` | add sheet (New plan / New routine) |
| AppBadge | `widgets/app_badge.md` | streak count |

## Screen-local elements

| Element | Type | Label | Behaviour |
|---------|------|-------|-----------|
| planHeader | Row | Plan name (uppercase) | streak flame (when > 0) + edit pencil → `plan-edit` |
| addFab | AppFab | "Add" | Opens the add sheet |
| addSheetNewPlan | row | "New plan" | Navigates to `plan-create` |
| addSheetNewRoutine | row | "New routine" | Navigates to `routine-create` |
| emptyState | Text | "Nothing here yet" | Shown when no plans and no routines |

## Navigation
- Entered from: app launch (home) · Workout tab
- Navigates to: `session-active` (start a routine) · `routine-edit` (tap a routine name) · `plan-edit` (pencil) · `routine-create` / `plan-create` (add sheet)
- Back behaviour: root route

## State dependencies
- `activePlansViewProvider` — active plans with their entries, per-entry done-this-week flag, and streak (served by the Plans/Progress services)
- `unplannedRoutinesProvider` — routines not referenced by any active plan
- `sessionEngineProvider` — to start a session

## Acceptance Criteria
- AC-001: Renders a plan block for each active plan, showing the plan name and an entry row per entry
- AC-002: Each plan entry shows its day label, routine name, and a done indicator reflecting whether it was completed this week
- AC-003: Tapping an entry's start button starts a session for that routine (with its plan context) and navigates to session-active
- AC-004: Renders an "Unplanned" block listing routines not in any active plan
- AC-005: Tapping the Add FAB opens a sheet offering "New plan" and "New routine"
- AC-006: Selecting "New routine" navigates to routine-create and "New plan" navigates to plan-create
- AC-007: Shows an empty state when there are no plans and no routines
- AC-008: A plan block shows its streak count when the streak is greater than zero
- AC-009: The screen reactively reflects newly created or modified plans and routines without an app restart — its data sources recompute when plans, plan entries, routines, or completed sessions change
- AC-010: Tapping a routine name (plan entry or unplanned) opens routine-edit for that routine
