---
name: AllPrs
type: screen
status: approved
---

## Description
The full list of all-time personal records, one per exercise (route `/progress/prs`), ranked by
estimated 1RM. Read-only.

## Layout

```
┌───────────────────────────────────────┐
│ ← PRsonal · All PRs                   │
├───────────────────────────────────────┤
│ 🏆 Bench Press · Jun 23, 2026 · 90kg  │
│ 🏆 Squat · Jun 18, 2026 · 140kg       │
└───────────────────────────────────────┘
```

## Widgets used

| Widget | Spec |
|--------|------|
| AppPageShell | shared |
| PrRow | `widgets/pr_row.md` |

## State dependencies
- `allPrsProvider` / `progressServiceProvider.allPRs`

## Navigation
- Entered from: Progress ("View all PRs")
- Back: returns to Progress

## Acceptance Criteria
- AC-001: Lists the best PR per exercise as a PR row
- AC-002: Shows an empty state when there are no PRs
