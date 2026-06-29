---
name: StatCard
type: widget
status: approved
---

## Description
A **flat metric tile** for the Progress KPI grid. Shows a large value with an uppercase label
beneath and an optional leading icon (e.g. the streak flame). Per [[design_system]] the tile carries
**no card chrome** (no fill, border or radius) — tiles are separated by whitespace within the grid.
The monochrome identity means `tone` no longer maps to a hue; it is retained as a no-op parameter
for call-site compatibility (the value's own sign carries up/down).

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| value | String | yes | — | Large value text (e.g. "12", "+8%") |
| label | String | yes | — | Uppercase caption (e.g. "WORKOUTS") |
| tone | StatTone | no | neutral | `neutral`, `success`, `danger`, `warning` |
| icon | IconData? | no | null | Leading icon |

`StatTone { neutral, success, danger, warning }`.

## Acceptance Criteria
- AC-001: Widget renders the value and label
- AC-002: Widget renders a leading icon when provided
- AC-003: Widget defaults to the neutral tone
- AC-004: Widget renders flat — no enclosing card chrome (no bordered/filled box)
