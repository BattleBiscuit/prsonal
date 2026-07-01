---
name: SessionProgressBar
type: widget
status: approved
---

## Description
The thin (3dp) progress strip at the very top of the active-session screen, ported from gym-app's
`SessionProgressBar`. A `surface-2` track with an `accent` fill whose width tracks the proportion
of completed sets. The fill animates width changes over 400ms.

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| progress | double | yes | — | Completed fraction, 0.0–1.0 |

## Visual States

| State | Appearance |
|-------|------------|
| default | 3dp tall; surface-2 track; accent fill at `progress` width |

## Acceptance Criteria
- AC-001: Widget renders a fill whose width factor equals progress
- AC-002: Widget clamps progress below 0 to 0 and above 1 to 1
- AC-003: A progress change animates the fill's width over `AppDurations.slow` (400ms) instead of
  snapping instantly
