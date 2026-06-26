---
name: <WidgetName>
type: widget
status: draft
---

## Description
One paragraph describing what this widget does, when it's used, and what makes it
distinct from a standard Flutter widget (why it exists as a custom component).

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| label | String | yes | — | Primary display text |
| onTap | VoidCallback? | no | null | Called on tap; widget is inert when null |

## Visual States

| State | Appearance |
|-------|------------|
| default | [description] |
| disabled | reduced opacity, no tap response |
| loading | spinner replaces content |
| error | red border, error icon |

## Accessibility
- Semantic label: [what screen-readers announce]
- Minimum touch target: 48×48 dp

## Acceptance Criteria
- AC-001: Widget renders [element] when [condition]
- AC-002: Widget calls onTap when tapped and onTap is non-null
- AC-003: Widget does not respond to taps when onTap is null
