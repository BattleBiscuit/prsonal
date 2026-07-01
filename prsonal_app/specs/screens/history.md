---
name: History
type: screen
status: approved
---

## Description
A chronological list of completed workouts (route `/progress/history`, reached from the Progress
area), grouped by month, newest first, with infinite scroll and per-card delete.

## Layout

```
┌───────────────────────────────────────┐
│ ← PRsonal · History                   │
├───────────────────────────────────────┤
│ JUNE 2026                             │
│ ┌ Push Day A                      🗑 ┐ │
│ │ Mon, 23 Jun · 47m · 4,230 kg      │ │
│ └───────────────────────────────────┘ │
│ MAY 2026 …                            │
└───────────────────────────────────────┘
```

## Widgets used

| Widget | Spec |
|--------|------|
| AppPageShell · AppModal | shared |
| HistoryCard | `widgets/history_card.md` |

## State dependencies
- `historyPageProvider` / `historyServiceProvider` — paged completed sessions + count

## Navigation
- Entered from: Progress screen (View all history) · after finishing a session (session-active)
- Navigates to: `history-detail` (tap a card)

## Acceptance Criteria
- AC-001: Lists completed sessions grouped by month, newest first
- AC-002: Each card shows the routine name, date, duration and volume
- AC-003: An abandoned session is labelled as abandoned
- AC-004: Tapping a card navigates to history-detail
- AC-005: Tapping delete confirms and then removes the session
- AC-006: Scrolling to the bottom loads the next page
- AC-007: Shows an empty state when there is no history
