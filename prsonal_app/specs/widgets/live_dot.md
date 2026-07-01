---
name: LiveDot
type: widget
status: approved
---

## Description
A small accent-coloured circle that marks a live/active context — a routine in progress, a
running timer. Ported from gym-app's `.live-dot`. Runs the "session heartbeat" breathing pulse
described in `design_system.md` ("Motion & life"): opacity and scale animate in a 1.6s loop so the
UI reads as *alive but still*. Purely decorative — excluded from the semantics tree.

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| size | double | no | 8 | Diameter in logical pixels |

## Visual States

| State | Appearance |
|-------|------------|
| default | `accent`-filled circle, opacity/scale breathing 0.4–1.0 / 0.85–1.0 over a 1.6s loop |
| reduced motion | static accent-filled circle at full opacity/scale — the loop is skipped, not just paused |

## Accessibility
- Decorative only: wrapped in `ExcludeSemantics`, announces nothing.

## Acceptance Criteria
- AC-001: Widget renders an accent-coloured circular dot of the given size
- AC-002: Widget's opacity/scale animates over a 1.6s loop when motion is not reduced
- AC-003: Widget renders statically (no animation) when `MediaQuery.disableAnimations` is true
- AC-004: Under reduced motion the animation ticker itself stops (not just its visual effect), so
  `pumpAndSettle` terminates
