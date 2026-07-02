---
name: AppBadge
type: widget
status: approved
---

## Description
A small pill label, ported from gym-app's `AppBadge`. Used for exercise type tags ("strength" /
"cardio"), set status ("✓" / "Skip"), and inline counts. Colour is chosen by `variant`.

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| label | String | yes | — | Badge text |
| variant | AppBadgeVariant | no | neutral | `neutral`, `success`, `danger`, `warning`, `accent` |

`AppBadgeVariant { neutral, success, danger, warning, accent }`.

## Visual States

| Variant | Background | Text |
|---------|-----------|------|
| neutral | surface-3 | text-2 |
| success | success @ 0.20 | success |
| danger | danger @ 0.20 | danger |
| warning | warning @ 0.20 | warning |
| accent | accent @ 0.15 | accent |

Shape: pill (radius full), padding 2×8, text xs/500, no wrap.

## Accessibility
- Semantic label: the `label` text

## Acceptance Criteria
- AC-001: Widget renders the label text
- AC-002: Widget defaults to the neutral variant when no variant is provided
- AC-003: Each variant renders its own distinct text color per the table above
