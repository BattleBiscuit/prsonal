---
name: RadarChart
type: widget
status: approved
---

## Description
The muscle-balance radar, ported from gym-app's Chart.js radar to `fl_chart`'s `RadarChart`. Plots
a single dataset across the seven fixed muscle axes (Chest, Shoulders, Arms, Back, Core, Legs,
Glutes) with an accent stroke and a 12%-accent fill.

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| data | Map\<Muscle, double\> | yes | — | Count per muscle (missing muscles treated as 0) |

## Visual States

| State | Appearance |
|-------|------------|
| with data | accent line (width 2), accent@0.12 fill, grid in surface-3, labels in text-2, draws in (scale 0→1, `normal`) |
| empty | empty-state caption "Not enough data yet" |

## Acceptance Criteria
- AC-001: Widget renders a radar chart for the provided muscle data
- AC-002: Widget shows an empty state when all muscle counts are zero
- AC-003: Widget scales in from 0 to 1 over `AppDurations.normal` on load
