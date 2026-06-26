---
name: BodyMetricCard
type: widget
status: approved
---

## Description
A metric tile in the Body screen grid, ported from gym-app's body metric cards. Shows an icon, the
metric label, the latest value with its unit (or a dash when none), the relative date, and a "+"
affordance. Tapping the card opens the log sheet for that metric.

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| label | String | yes | — | e.g. "Bodyweight" |
| valueLabel | String | yes | — | e.g. "82.5 kg" or "—" |
| dateLabel | String? | no | null | e.g. "Today", "Jun 23" |
| icon | IconData | yes | — | Leading icon |
| onTap | VoidCallback | yes | — | Open the log sheet |

## Acceptance Criteria
- AC-001: Widget renders the metric label and value
- AC-002: Widget renders the date label when provided
- AC-003: Widget calls onTap when tapped
