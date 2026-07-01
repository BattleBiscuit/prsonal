---
name: PrRow
type: widget
status: approved
---

## Description
A personal-record row, ported from gym-app's PR list rows. Shows a trophy icon, the exercise name
and date, and the best weight with its estimated 1RM. Used on the Progress screen and the All-PRs
screen. When `celebrate` is set (the row for a PR that was *just* set), it plays the one-shot "PR
moment" motion from `design_system.md` ("Motion & life" / "Depth & elevation"): a brief `accent`
background flash plus a number-roll pop on the weight value, once, on mount.

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| exerciseName | String | yes | — | Exercise name |
| dateLabel | String | yes | — | e.g. "Jun 23" |
| weightLabel | String | yes | — | Best weight, e.g. "90kg" |
| oneRmLabel | String | yes | — | e.g. "1RM: 95kg" |
| onTap | VoidCallback? | no | null | Optional tap handler |
| celebrate | bool | no | false | Plays the one-shot PR flash + number-roll on mount |

## Acceptance Criteria
- AC-001: Widget renders the exercise name, date, weight and 1RM
- AC-002: Widget calls onTap when tapped and onTap is non-null
- AC-003: When celebrate is true, the row plays a one-shot accent background flash that decays to
  transparent
- AC-004: When celebrate is false (the default), the row renders with no background flash
