---
name: AppFab
type: widget
status: approved
---

## Description
The floating action button, ported from gym-app's `AppFab`. A pill-shaped accent button with a
leading icon and a text label, fixed at the bottom-right above the bottom navigation. Used for the
primary "create/add/save" action on a screen (e.g. "+ New", "✓ Save").

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| label | String | yes | — | Button text |
| icon | IconData | yes | — | Leading icon |
| onPressed | VoidCallback? | no | null | Tap handler; disabled when null |

## Visual States

| State | Appearance |
|-------|------------|
| default | accent bg, onAccent icon+text, pill radius, height 48, padding 0×20, text sm/700, shadow `0 4 16 black@0.40` |
| pressed | accentDim bg |
| disabled (onPressed null) | opacity 0.4 |

Position: `right: 16`, `bottom: navHeight + safeBottom + 16` (placed by the host screen).

## Accessibility
- Semantic label: the `label` text
- Minimum touch target: 48 dp height

## Acceptance Criteria
- AC-001: Widget renders the label
- AC-002: Widget renders the leading icon
- AC-003: Widget calls onPressed when tapped and onPressed is non-null
- AC-004: Widget does not call onPressed when onPressed is null
