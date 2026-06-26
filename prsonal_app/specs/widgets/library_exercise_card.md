---
name: LibraryExerciseCard
type: widget
status: approved
---

## Description
An exercise row in the library list, ported from gym-app's lib-card. Shows the name, a type badge
(strength/cardio), the primary muscles, and a PR chip when a best lift exists, plus a delete
button.

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| name | String | yes | — | Exercise name |
| type | ExerciseType | yes | — | strength / cardio (badge) |
| musclesLabel | String | yes | — | e.g. "Chest, Shoulders" |
| prLabel | String? | no | null | e.g. "🏆 95kg" when a PR exists |
| onTap | VoidCallback | yes | — | Open the editor |
| onDelete | VoidCallback | yes | — | Delete the exercise |

## Acceptance Criteria
- AC-001: Widget renders the name and a type badge
- AC-002: Widget renders the primary muscles label
- AC-003: Widget renders a PR chip when prLabel is provided and omits it when null
- AC-004: Widget calls onTap when the card body is tapped
- AC-005: Widget calls onDelete when the delete button is tapped
