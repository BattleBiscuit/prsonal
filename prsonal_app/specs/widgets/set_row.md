---
name: SetRow
type: widget
status: approved
---

## Description
A single set within the active-session exercise list, ported from gym-app's `SetRow`. Renders in
one of four states — upcoming, active (editable), completed, or skipped — sharing a consistent
column layout (set number · values · status). The active row exposes editable inputs and a
complete checkbox; completed rows show logged values, an optional PR indicator, and a checked
state.

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| index | int | yes | — | 0-based set index (displayed as index+1) |
| kind | ExerciseType | yes | — | strength vs cardio (input shape) |
| status | ActiveSetStatus | yes | — | `upcoming`, `active`, `completed`, `skipped` |
| plannedLabel | String | yes | — | Target shown as a ghost on the active/upcoming row |
| actualLabel | String? | no | null | Logged values shown on a completed row |
| isPR | bool | no | false | Completed set set a personal record |
| isBodyweight | bool | no | false | Active row's bodyweight toggle state |
| primaryValue | String? | no | null | Active row primary input (reps / minutes) |
| secondaryValue | String? | no | null | Active row secondary input (kg / level) |
| onPrimaryChanged | ValueChanged\<String\>? | no | null | Active row primary edit |
| onSecondaryChanged | ValueChanged\<String\>? | no | null | Active row secondary edit |
| onToggleBodyweight | VoidCallback? | no | null | Active row BW toggle |
| onToggleComplete | VoidCallback? | no | null | Checkbox toggled (complete / uncheck) |
| onSelect | VoidCallback? | no | null | Tapped an upcoming row to make it active |

`ActiveSetStatus { upcoming, active, completed, skipped }`.

## Visual States

| State | Appearance |
|-------|------------|
| upcoming | set number + ghost planned label; tappable to select; muted |
| active | **Tier 3 live row**: a faint `accent @ 0.06` tint with a **2px `accent` left rail** and light (`text1`) content — light set number, light-text inputs and unchecked box, each with a **thicker 2px `accent @ 0.30`** contour (never a white outline). The live focus, without the glare of a solid block. |
| completed | logged values at full strength in `text1`; `success` checked box; optional `warning` PR **star**; no blanket dimming |
| skipped | struck-through planned label in `text3` + a readable "Skip" badge (`surface3`/`text2`); non-interactive |

The active row is the design system's Tier 3 "state-proposing / act here now" moment, rendered as
the **live "you are here" row**: a faint accent tint plus a 2px accent left rail lifts the live set
out of the historical (Tier 2) logs around it without the glare of a full chalk-on-dark inversion.

## Accessibility
- PR indicator semantic label: "Personal record"
- Complete checkbox minimum touch target: 48 dp

## Acceptance Criteria
- AC-001: An upcoming set renders its set number and planned target
- AC-002: The active set renders editable primary and secondary inputs and a complete checkbox
- AC-003: A completed set renders its logged values in a checked state
- AC-004: A completed set that set a personal record renders a PR indicator
- AC-005: A skipped set renders a skipped treatment
- AC-006: Tapping the active set's checkbox invokes onToggleComplete
- AC-007: The active set's inputs display the provided primaryValue and secondaryValue and preserve typed input across rebuilds
- AC-008: The active set renders as a Tier 3 live row — a faint accent tint background with a 2px accent left rail and light (text1) content
