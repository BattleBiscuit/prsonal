---
name: AppFab
type: widget
status: approved
---

## Description
The floating action button, ported from gym-app's `AppFab`. Fixed at the bottom-right above the
bottom navigation. Used for the primary "create/add/save" action on a screen. Per
[[design_system]]'s icon-only-affordance decision, the default shape is a **bare-icon circular
accent pill** (e.g. the Workout/Exercises "add" FAB); an extended icon+label pill remains available
for call sites that want a worded FAB (e.g. "+ New", "✓ Save").

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| label | String? | no | null | Button text; when omitted, renders the bare-icon circular form |
| icon | IconData | yes | — | Icon (leading icon in labelled form, sole glyph in bare form) |
| onPressed | VoidCallback? | no | null | Tap handler; disabled when null |
| tooltip | String? | no | null | Accessibility/discoverability tooltip; **required when `label` is omitted** (the bare-icon form has no visible text, so the tooltip is its only affordance label). When both are set, the tooltip wins over the label as the accessible name. |

## Visual States

| Form | Appearance |
|------|------------|
| labelled (`label` set) | accent bg, onAccent icon+text, pill radius, height 48, padding 0×20, text sm/700, shadow `0 4 16 black@0.40` |
| bare-icon (`label` omitted) | accent bg, onAccent icon, fully round `radiusFull` circle, 48×48 min, shadow `0 4 16 black@0.40` |
| pressed (either form) | accentDim bg |
| disabled (onPressed null) | opacity 0.4 |

Position: `right: 16`, `bottom: navHeight + safeBottom + 16` (placed by the host screen).

## Accessibility
- Every instance carries a `Tooltip` — `tooltip` if provided, otherwise `label`.
- Minimum touch target: 48 dp (height in labelled form, both dimensions in bare-icon form).

## Acceptance Criteria
- AC-001: Widget renders the label when provided
- AC-002: Widget renders the icon
- AC-003: Widget calls onPressed when tapped and onPressed is non-null
- AC-004: Widget does not call onPressed when onPressed is null
- AC-005: Widget renders the bare-icon circular form (no visible text) when label is omitted
- AC-006: Widget exposes a Tooltip with the given tooltip text, or the label when tooltip is omitted
