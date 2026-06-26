---
name: VolumeChart
type: widget
status: approved
---

## Description
The per-workout volume bar chart, ported from gym-app's Chart.js bar chart to `fl_chart`'s
`BarChart`. One accent bar per session, rounded tops, with a kg/tonne y-axis.

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| data | List\<({String label, double volume})\> | yes | — | One entry per session, oldest→newest |

## Visual States

| State | Appearance |
|-------|------------|
| with data | accent@0.5 bars, accent border, rounded top (radius 4); y-axis formats ≥1000 as "Xt" |
| empty | empty-state caption "No volume yet" |

## Acceptance Criteria
- AC-001: Widget renders a bar chart for the provided data
- AC-002: Widget shows an empty state when there is no data
