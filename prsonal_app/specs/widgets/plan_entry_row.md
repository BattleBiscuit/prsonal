---
name: PlanEntryRow
type: widget
status: approved
---

## Description
A single routine row on the Workout (session-pick) screen, ported from gym-app's plan entry /
unplanned routine rows. Shows a day label, the routine name, a done-this-week indicator, and a
start (▶) button. Used both inside plan blocks (with a day label) and in the Unplanned block
(day label "·").

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| dayLabel | String | yes | — | "Mon"–"Sun" or "·" |
| routineName | String | yes | — | Routine name |
| done | bool | no | false | Completed this week |
| startDisabled | bool | no | false | Disable start (e.g. a session is already active) |
| onStart | VoidCallback? | no | null | Tapped the start (▶) button |
| onOpen | VoidCallback? | no | null | Tapped the routine name (open editor) |

## Visual States

| State | Appearance |
|-------|------------|
| default | day label (text-3) · routine name (text-1, medium) · done dot · accent ▶ start button |
| done | done indicator is a success ✓ |
| startDisabled | start button at opacity 0.3, inert |

## Accessibility
- Done indicator semantic label (when done): "Completed this week"
- Start button semantic label: "Start {routineName}"

## Acceptance Criteria
- AC-001: Widget renders the day label and routine name
- AC-002: Widget renders a "Completed this week" indicator when done is true
- AC-003: Widget calls onStart when the start button is tapped
- AC-004: The start button is inert when startDisabled is true
