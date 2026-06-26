---
name: HistorySetTable
type: widget
status: approved
---

## Description
A per-exercise table of sets on the History detail screen, ported from gym-app's `HistorySetTable`.
Each row shows the set number, the planned target, the actual logged values (with a PR indicator
and a delta), and a status. In edit mode the actual columns become editable inputs.

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| exerciseName | String | yes | — | Exercise name (table heading) |
| rows | List\<SetTableRow\> | yes | — | One per set |
| editing | bool | no | false | Switch actual columns to inputs |
| onRowChanged | void Function(int index, SetTableEdit edit)? | no | null | Edit callback |

`SetTableRow { setIndex, plannedLabel, actualLabel?, skipped, isPR, kind, primaryValue?, secondaryValue? }`.

## Visual States

| State | Appearance |
|-------|------------|
| completed row | actual in success; optional PR trophy; ✓ badge |
| skipped row | "Skip" badge, 45% opacity |
| editing | actual cells become two inputs (+ BW toggle for strength) |

## Acceptance Criteria
- AC-001: Widget renders the exercise name and a row per set with planned and actual values
- AC-002: A PR set shows a PR indicator
- AC-003: A skipped set is shown distinctly
- AC-004: In editing mode the actual values become editable inputs
