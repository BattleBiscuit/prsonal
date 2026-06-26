---
name: StatCard
type: widget
status: approved
---

## Description
A metric tile, ported from gym-app's progress metric cards. Shows a large value with an uppercase
label beneath, optionally tinted (e.g. green up / red down / warning streak) and with a leading
icon (e.g. the streak flame).

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
