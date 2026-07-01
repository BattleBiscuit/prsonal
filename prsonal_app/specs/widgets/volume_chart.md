---
name: VolumeChart
type: widget
status: approved
---

## Description
The per-workout volume bar chart, ported from gym-app's Chart.js bar chart to `fl_chart`'s
`BarChart`. One bar per session; per `design_system.md` ("Data visualisation"), all bars render at
`accent@0.50` except the **latest bar**, which renders at full `accent` as the emphasized
endpoint, over a faint `surface3` baseline. Bars grow on load (`AppDurations.normal`, staggered
per bar). Squared corners (`radiusMd` = 0), matching the app's flat/hard-edged visual language —
no rounding.

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| data | List\<({String label, double volume})\> | yes | — | One entry per session, oldest→newest |

## Visual States

| State | Appearance |
|-------|------------|
| with data | bars `accent@0.50`, latest bar full `accent`, squared (no radius); faint `surface3` baseline; `mono` tabular axis labels |
| loading in | bars grow from 0 to their target height over `AppDurations.normal`, staggered per bar index |
| reduced motion | bars render at full height immediately — the grow-in is skipped, not just paused |
| empty | empty-state caption "No volume yet" |

## Acceptance Criteria
- AC-001: Widget renders a bar chart for the provided data
- AC-002: Widget shows an empty state when there is no data
- AC-003: The latest (last) bar renders at full accent opacity while all other bars render at
  accent@0.50
- AC-004: Widget renders a faint surface3 baseline
- AC-005: Bars grow from 0 to their target height on load when motion is not reduced, and render
  at full height immediately when `MediaQuery.disableAnimations` is true
