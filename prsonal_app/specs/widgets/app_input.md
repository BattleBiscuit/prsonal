---
name: AppInput
type: widget
status: approved
---

## Description
A labelled single-line text field, ported from gym-app's `AppInput`. Renders an optional label
above a `surface-2` field with an accent focus border and an optional error message below. Used
for names (routine, plan, exercise) and numeric entry (reps, weight, rest, body values).

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| value | String? | no | null | Current text |
| label | String? | no | null | Label shown above the field |
| placeholder | String? | no | null | Hint text shown when empty |
| onChanged | ValueChanged\<String\>? | no | null | Called with the new text on every edit |
| keyboardType | TextInputType? | no | null | e.g. number/decimal for numeric fields |
| errorText | String? | no | null | Error message shown below; field shows an error border |
| enabled | bool | no | true | When false the field is non-editable at opacity 0.4 |

## Visual States

| State | Appearance |
|-------|------------|
| default | surface-2 bg, 1px border, radius md, text-1, min-height 48, padding 0×16 |
| focused | 2px accent border |
| error | 2px danger border; error text below in danger, xs |
| disabled | opacity 0.4, non-editable |

## Accessibility
- Semantic label: the `label` text
- Minimum touch target: 48 dp height

## Acceptance Criteria
- AC-001: Widget renders the label when provided
- AC-002: Widget renders the placeholder hint when provided
- AC-003: Widget calls onChanged with the entered text
- AC-004: Widget displays the error text when errorText is provided
- AC-005: Widget is non-editable when enabled is false
