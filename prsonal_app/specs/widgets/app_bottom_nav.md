---
name: AppBottomNav
type: widget
status: implemented
---

## Description
App-wide persistent bottom navigation bar with five tabs. Present on every root-level screen; hidden during an active workout session. The active tab is highlighted in the brand accent colour.

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| currentIndex | int | yes | — | 0-based index of the active tab |
| onTabSelected | void Function(int) | yes | — | Called with the tapped tab index |

## Tabs (fixed order)

| Index | Label | Route |
|-------|-------|-------|
| 0 | Workout | /session |
| 1 | Exercises | /library |
| 2 | Body | /body |
| 3 | Progress | /progress |
| 4 | Settings | /settings |

## Visual States

| State | Appearance |
|-------|------------|
| inactive tab | Icon and label in tertiary text colour |
| active tab | Icon and label in accent colour |
| hidden | Not rendered when an active workout session exists |

## Accessibility
- Each tab has a semantic label matching its Label text
- Minimum touch target per tab: 48×48 dp

## Acceptance Criteria
- AC-001: Widget renders exactly five tabs in the fixed order above
- AC-002: The tab at currentIndex renders in accent colour; all others render in tertiary text colour
- AC-003: Widget calls onTabSelected with the correct index when a tab is tapped
- AC-004: Widget is not rendered when a workout session is active
