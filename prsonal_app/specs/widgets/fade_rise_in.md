---
name: FadeRiseIn
type: widget
status: approved
---

## Description
The "on load" motion from `design_system.md` ("Motion & life"): content fades in and rises 8
logical pixels into place over `AppDurations.normal` (200ms) the first time it appears, instead of
popping in instantly. Wraps a single child; screens use it around list-row/section content (each
`ListView.builder` item, a section on first paint) so the app reads as *alive but still* rather
than static.

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| child | Widget | yes | — | Content to fade+rise in |

## Visual States

| State | Appearance |
|-------|------------|
| default | opacity 0→1 and translateY +8→0dp over `AppDurations.normal`, once, on mount |
| reduced motion | child renders immediately at its final position/opacity — the animation is skipped, not just paused |

## Accessibility
- Purely presentational — does not alter the child's semantics.

## Acceptance Criteria
- AC-001: Widget renders its child
- AC-002: On mount, the child animates from 0 opacity / +8dp offset to 1 opacity / 0dp offset over
  AppDurations.normal when motion is not reduced
- AC-003: Widget renders the child immediately at full opacity and no offset when
  `MediaQuery.disableAnimations` is true
