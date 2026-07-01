---
name: Progress
type: screen
status: approved
---

## Description
The analytics dashboard (Progress tab, route `/progress`). A range-filterable view of workout
stats: a 2×2 metric grid, a swipeable chart slider (muscle-balance radar + per-workout volume),
recent PRs, and a recent-history preview.

## Layout

```
┌───────────────────────────────────────┐
│ PRsonal · Progress        4w 8w All   │
├───────────────────────────────────────┤
│ [ 12 WORKOUTS ] [ +8% VOL TREND ]     │
│ [ 87% ADHERENCE ] [ 🔥3 STREAK ]      │
│ ◀ ChartSlider: Muscle balance / Volume ▶│
│ RECENT PRS                          › │
│ Bench Press · Jun 23 · 90kg           │
│ WORKOUT HISTORY                     › │
│ Push Day A · Jun 23 · 4,230 kg        │
└───────────────────────────────────────┘
```

## Widgets used

| Widget | Spec |
|--------|------|
| AppPageShell | shared |
| StatCard | `widgets/stat_card.md` |
| ChartSlider · MuscleRadarChart · VolumeChart | progress charts |
| PrRow | `widgets/pr_row.md` |

## State dependencies
- `progressRangeProvider` (4w / 8w / all) and `progressServiceProvider` derivations
- `historyServiceProvider` — the recent-history preview

## Navigation
- Navigates to: `all-prs` (View all PRs) · `history` (View all history) · `history-detail` (preview row)

## Acceptance Criteria
- AC-001: Renders the workout-count, volume-trend, plan-adherence and best-streak metric cards
- AC-002: Changing the range toggle reloads the metrics for that range
- AC-003: Renders a chart slider containing the muscle-balance and volume charts
- AC-004: Renders recent PRs, each as a PR row
- AC-005: "View all PRs" navigates to all-prs
- AC-006: A history preview row navigates to history-detail
- AC-007: "View all history" navigates to history
- AC-008: A history preview row carries a trailing affordance icon (design_system.md Tier 1: "no
  interactive row is left bare")
