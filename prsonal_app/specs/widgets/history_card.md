---
name: HistoryCard
type: widget
status: approved
---

## Description
A completed-workout row in the History list, ported from gym-app's `HistoryCard`. Shows the
routine name (with an "· Abandoned" suffix in warning colour when abandoned), the date, and a
"duration · volume" meta line, plus a delete button.

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
