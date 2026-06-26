---
name: RestActionButton
type: widget
status: approved
---

## Description
The full-width bottom action control on the active-session screen, ported from gym-app's inline
bottom button. In its normal state it is an accent button showing the supplied label
("Done" / "Finish") that completes the current set. While a rest timer is running it switches to a
`surface-1` button showing "Rest Ns" with an accent countdown ring; tapping it skips the rest.

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| resting | bool | yes | — | Whether a rest timer is running |
| remainingSeconds | int | no | 0 | Seconds left when resting |
| label | String | yes | — | Action label when not resting (e.g. "Done", "Finish") |
| onPressed | VoidCallback | yes | — | Complete the set (normal) or skip the rest (resting) |

## Visual States

| State | Appearance |
|-------|------------|
| normal | accent bg, onAccent text, label + ✓ icon, min-height 52, radius lg |
| resting | surface-1 bg, text-1, "Rest Ns", accent countdown ring border |

## Acceptance Criteria
- AC-001: When not resting, widget renders the given label
- AC-002: When resting, widget renders the remaining seconds as "Rest Ns"
- AC-003: Widget calls onPressed when tapped
