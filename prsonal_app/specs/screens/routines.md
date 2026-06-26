---
name: Routines
type: screen
status: approved
---

## Description
The routine library list (route `/routines`, reached from the Workout tab's add flow and from
editing). Lists every routine as a [[routine_card]], most-recently-updated first, with a "+ New"
action in the header and tap-to-edit / delete per card.

## Layout

```
┌───────────────────────────────────────┐
│ PRsonal · Routines            + New    │
├───────────────────────────────────────┤
│ ┌ Push Day A ─────────────────── 🗑 ┐ │
│ │ 3 exercises · Updated 2h ago      │ │
│ │ Heavy day                          │ │
│ └───────────────────────────────────┘ │
│ ... more cards ...                    │
└───────────────────────────────────────┘
```

## Widgets used

| Widget | Spec | Usage |
|--------|------|-------|
| AppPageShell | `widgets/app_page_shell.md` | header = "Routines" + New button |
| RoutineCard | `widgets/routine_card.md` | one per routine |
| AppModal | `widgets/app_modal.md` | delete confirmation |

## State dependencies
- `routinesListProvider` — `Stream<List<RoutineSummary>>` from [[routines_service]]

## Navigation
- Entered from: add sheet (session-pick) · after saving a routine
- Navigates to: `routine-create` (+ New) · `routine-edit` (tap card)

## Acceptance Criteria
- AC-001: Renders a card for each routine with its name and meta line
- AC-002: Tapping a routine card navigates to routine-edit
- AC-003: Tapping "+ New" navigates to routine-create
- AC-004: Tapping a card's delete opens a confirm modal and confirming deletes the routine
- AC-005: Shows an empty state when there are no routines
