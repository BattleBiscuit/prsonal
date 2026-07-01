---
name: BodyMetricCard
type: widget
status: approved
---

## Description
A **flat metric tile** in the Body screen 2-column grid. Shows an icon, the metric label, a
trailing `edit_outlined` (text2) marking the tile's tap-to-log affordance — per [[design_system]]'s
Tier 1 rule ("no interactive row is left bare") and its canonical icon-affordance map (edit →
`edit_outlined`) — the latest value with its unit (or a dash when none), and the relative date.
Tapping the tile opens the log sheet for that metric. Per [[design_system]] the tile carries **no
card chrome** (no fill, border or radius) — tiles are separated by whitespace within the grid, not
boxed.

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
- AC-004: Widget renders flat — no enclosing card chrome (no bordered/filled box)
- AC-005: Widget renders a trailing edit affordance icon marking the tile as interactive
