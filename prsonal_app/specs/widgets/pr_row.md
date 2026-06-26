---
name: PrRow
type: widget
status: approved
---

## Description
A personal-record row, ported from gym-app's PR list rows. Shows a trophy icon, the exercise name
and date, and the best weight with its estimated 1RM. Used on the Progress screen and the All-PRs
screen.

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| exerciseName | String | yes | — | Exercise name |
| dateLabel | String | yes | — | e.g. "Jun 23" |
| weightLabel | String | yes | — | Best weight, e.g. "90kg" |
| oneRmLabel | String | yes | — | e.g. "1RM: 95kg" |
| onTap | VoidCallback? | no | null | Optional tap handler |

## Acceptance Criteria
- AC-001: Widget renders the exercise name, date, weight and 1RM
- AC-002: Widget calls onTap when tapped and onTap is non-null
