---
name: AppSkeleton
type: widget
status: approved
---

## Description
The shared loading placeholder from `design_system.md` ("Depth & elevation" — skeleton loaders are
one of the few surfaces allowed the filled `surface1` treatment; "Motion & life" — skeleton content
pulses rather than sitting static). A flat `surface1` rectangle whose opacity breathes 1 → 0.4 → 1
on a 1.5s loop while content is loading. Screens compose one or more `AppSkeleton`s (stacked in a
`Column`) to sketch the shape of the content that is about to arrive, instead of a bare spinner.

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| width | double? | no | null (fills available width) | Placeholder width |
| height | double | no | 16 | Placeholder height |

## Visual States

| State | Appearance |
|-------|------------|
| default | `surface1` rectangle, opacity pulsing 1 → 0.4 → 1 over a 1.5s loop |
| reduced motion | static `surface1` rectangle at full opacity — the loop is skipped, not just paused |

## Accessibility
- Decorative only: wrapped in `ExcludeSemantics`, announces nothing.

## Acceptance Criteria
- AC-001: Widget renders a surface1 rectangle of the given width and height
- AC-002: Widget's opacity animates over a 1.5s loop when motion is not reduced
- AC-003: Widget renders statically (no animation) when `MediaQuery.disableAnimations` is true
- AC-004: Under reduced motion the animation ticker itself stops (not just its visual effect), so
  `pumpAndSettle` terminates
