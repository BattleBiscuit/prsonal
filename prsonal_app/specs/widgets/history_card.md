---
name: HistoryCard
type: widget
status: approved
---

## Description
A completed-workout **flat row** in the History list. Shows the routine name (with an "· Abandoned"
suffix in warning colour when abandoned), the date, and a "duration · volume" meta line, plus a
delete button and a trailing `chevron_right_outlined` (text2) marking the row's own tap-to-open
affordance — per [[design_system]]'s Tier 1 rule ("no interactive row is left bare"), the delete
icon maps to a *different* action than the row's `onTap`, so the navigate affordance needs its own
glyph. Per [[design_system]] the row carries **no card chrome** (no fill, border or radius) —
grouped sections separate rows with hairline dividers.

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| routineName | String | yes | — | Routine name |
| dateLabel | String | yes | — | e.g. "Mon, 23 Jun" |
| metaLabel | String | yes | — | e.g. "47m · 4,230 kg" |
| abandoned | bool | no | false | Append "· Abandoned" (warning) |
| onTap | VoidCallback | yes | — | Open the detail screen |
| onDelete | VoidCallback | yes | — | Delete this session |

## Accessibility
- Delete button semantic label: "Delete workout"

## Acceptance Criteria
- AC-001: Widget renders the routine name, date and meta line
- AC-002: Widget renders an "Abandoned" label when abandoned is true
- AC-003: Widget calls onTap when the card body is tapped
- AC-004: Widget calls onDelete when the delete button is tapped
- AC-005: Widget renders flat — no enclosing card chrome (no bordered/filled box)
- AC-006: Widget renders a trailing chevron marking the row's own navigate affordance, distinct
  from the delete icon
