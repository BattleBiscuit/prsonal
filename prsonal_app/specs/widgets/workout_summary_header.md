---
name: WorkoutSummaryHeader
type: widget
status: approved
---

## Description
The summary block at the top of the History detail screen, ported from gym-app's
`WorkoutSummaryHeader`. Shows the date/time line, the routine name, and three stat tiles:
duration, total volume, and status.

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| routineName | String | yes | — | Routine name |
| dateTimeLabel | String | yes | — | e.g. "Mon, 23 Jun at 09:15 AM" |
| durationLabel | String | yes | — | e.g. "47m" |
| volumeLabel | String | yes | — | e.g. "4,230 kg" |
| statusLabel | String | yes | — | "Completed" or "Abandoned" |

## Acceptance Criteria
- AC-001: Widget renders the date/time line and routine name
- AC-002: Widget renders three stat tiles for duration, total volume and status
