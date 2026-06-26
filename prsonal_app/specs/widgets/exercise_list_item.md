---
name: ExerciseListItem
type: widget
status: approved
---

## Description
A row in the routine editor's exercise list, ported from gym-app's `ExerciseListItem`. Shows a
drag handle, the exercise name, a sets summary ("3 sets · 10×80kg, …"), an optional notes line,
and a delete button. Tapping the body opens the exercise form to edit it.

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| name | String | yes | — | Exercise name |
| setsSummary | String | yes | — | e.g. "3 sets · 10×80kg" |
| notes | String? | no | null | Optional notes preview |
| onTap | VoidCallback | yes | — | Open the exercise form to edit |
| onDelete | VoidCallback | yes | — | Remove this exercise |

## Visual States

| State | Appearance |
|-------|------------|
| default | surface-1, border, radius md; drag handle (☰) left; name (base/500); summary (sm/text-2) |

## Accessibility
- Drag handle semantic label: "Reorder exercise"
- Delete button semantic label: "Remove exercise"

## Acceptance Criteria
- AC-001: Widget renders the exercise name and sets summary
- AC-002: Widget renders a drag handle
- AC-003: Widget calls onTap when the body is tapped
- AC-004: Widget calls onDelete when the delete button is tapped
