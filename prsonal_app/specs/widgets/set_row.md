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
| active | **Tier 3 polarity inversion**: solid `accent` chalk block with `onAccent` (`#0F0F0F`) content — dark set number, dark-text inputs with dark contours, dark unchecked box. The single loudest element in the session. |
| completed | logged values in success; optional PR trophy; ▲/▼/= delta; checked box; 0.65 opacity |
| skipped | "Skip" badge, 0.35 opacity, non-interactive |

The active row is the design system's canonical Tier 3 "state-proposing / act here now" moment: it
inverts the dark-on-light system rule to a chalk-on-dark block so the live set snaps out from the
historical (Tier 2) logs around it.

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
- AC-008: The active set renders as a Tier 3 polarity-inverted block — a solid accent (chalk) background with onAccent (dark) content
