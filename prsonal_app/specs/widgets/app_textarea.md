---
name: AppTextarea
type: widget
status: approved
---

## Description
A labelled multi-line text field, ported from gym-app's `AppTextarea`. Same surface/focus styling
as AppInput but renders several rows and has no error state. Used for routine, plan, exercise, and
session notes.

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| value | String? | no | null | Current text |
| label | String? | no | null | Label shown above the field |
| placeholder | String? | no | null | Hint text shown when empty |
| onChanged | ValueChanged\<String\>? | no | null | Called with the new text on every edit |
| rows | int | no | 3 | Visible line count (maps to maxLines) |
| enabled | bool | no | true | When false the field is non-editable at opacity 0.4 |

## Visual States

| State | Appearance |
|-------|------------|
| default | surface-2 bg, 1px border, radius md, text-1, padding 12×16 |
| focused | 2px accent border |
| disabled | opacity 0.4, non-editable |

## Accessibility
- Semantic label: the `label` text

## Acceptance Criteria
- AC-001: Widget renders the label when provided
- AC-002: Widget renders the configured number of rows (maxLines equals rows)
- AC-003: Widget calls onChanged with the entered text
- AC-004: Widget is non-editable when enabled is false
