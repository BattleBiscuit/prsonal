---
name: RoutineCard
type: widget
status: approved
---

## Description
A tappable **flat row** representing a routine in the Routines list. Shows the routine name, a meta
line ("N exercises · Updated 2h ago"), an optional 2-line notes preview, and a delete button.
Per [[design_system]] the row carries **no card chrome** (no fill, border or radius) — the list
separates rows with a hairline divider.

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| name | String | yes | — | Routine name |
| metaLine | String | yes | — | e.g. "3 exercises · Updated 2h ago" |
| notes | String? | no | null | Notes preview (clamped to 2 lines) |
| onTap | VoidCallback | yes | — | Open the routine editor |
| onDelete | VoidCallback | yes | — | Delete this routine |

## Visual States

| State | Appearance |
|-------|------------|
| default | flat row, no fill/border/radius; name (base/600), meta (sm/text-2), notes (sm/text-3) |
| pressed | ink ripple |

## Accessibility
- Delete button semantic label: "Delete routine"

## Acceptance Criteria
- AC-001: Widget renders the routine name and meta line
- AC-002: Widget renders the notes preview when provided and omits it when null
- AC-003: Widget calls onTap when the card body is tapped
- AC-004: Widget calls onDelete when the delete button is tapped
- AC-005: Widget renders flat — no enclosing card chrome (no bordered/filled box)
