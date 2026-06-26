---
name: DayOfWeekSelector
type: widget
status: approved
---

## Description
A row of seven day toggle buttons (Mon–Sun), ported from gym-app's plan entry day picker. A single
day may be selected; tapping the selected day clears it (unscheduled). Used per plan entry in the
plan editor.

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| selected | int? | no | null | Selected day, 0 = Mon … 6 = Sun; null = unscheduled |
| onChanged | void Function(int?) | yes | — | Called with the new selection (null when deselected) |

## Visual States

| State | Appearance |
|-------|------------|
| unselected day | surface-2 chip, text-2 |
| selected day | accent chip, onAccent bold text |

## Acceptance Criteria
- AC-001: Widget renders seven day buttons labelled Mon, Tue, Wed, Thu, Fri, Sat, Sun
- AC-002: Widget highlights the selected day
- AC-003: Tapping a day calls onChanged with that day index
- AC-004: Tapping the currently selected day calls onChanged with null
