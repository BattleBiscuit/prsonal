---
name: LibraryExerciseCard
type: widget
status: approved
---

## Description
An exercise **flat row** in the library list. Shows the name, a type badge (strength/cardio), the
primary muscles, and a PR chip when a best lift exists, plus a delete button. Per [[design_system]]
the row carries **no card chrome** (no fill, border or radius) — the list separates rows with a
hairline divider. (The type badge keeps its own small filled pill; that is not card chrome.)

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
- AC-006: Widget renders flat — no enclosing card chrome (the row itself has no bordered/filled box)
