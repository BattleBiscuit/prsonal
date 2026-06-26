---
name: SessionHeader
type: widget
status: approved
---

## Description
The fixed header of the active-session screen, ported from gym-app's `SessionHeader`. Shows the
routine name, the elapsed time (monospaced), and two circular actions: quit (danger ✕) and finish
(accent ✓).

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| routineName | String | yes | — | Current routine name |
| elapsed | Duration | yes | — | Time since the session started |
| onQuit | VoidCallback | yes | — | Tapped the quit (✕) action |
| onFinish | VoidCallback | yes | — | Tapped the finish (✓) action |

Elapsed is formatted `M:SS` under an hour and `H:MM:SS` at or above an hour.

## Visual States

| State | Appearance |
|-------|------------|
| default | routine name (text-2, sm, truncated) · elapsed (text-3, mono) · ✕ danger 32dp circle · ✓ accent 32dp circle |

## Accessibility
- Quit action semantic label: "Quit workout"
- Finish action semantic label: "Finish workout"

## Acceptance Criteria
- AC-001: Widget renders the routine name
- AC-002: Widget renders the elapsed time formatted as M:SS under an hour
- AC-003: Widget calls onQuit when the quit action is tapped
- AC-004: Widget calls onFinish when the finish action is tapped
