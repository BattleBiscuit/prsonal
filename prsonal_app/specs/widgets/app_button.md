---
name: AppButton
type: widget
status: approved
---

## Description
The app's standard button, ported from gym-app's `AppButton`. A single component covering every
button style via a `variant`, in two sizes, optionally full-width and with a leading icon. It
exists (rather than using raw `ElevatedButton`/`OutlinedButton`) so every button shares the exact
gym-app sizing, radius, and the four colour treatments.

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| label | String | yes | — | Button text |
| onPressed | VoidCallback? | no | null | Tap handler; button is disabled when null |
| variant | AppButtonVariant | no | primary | `primary`, `ghost`, `danger`, `accent` |
| size | AppButtonSize | no | md | `md` (48dp), `sm` (36dp) |
| full | bool | no | false | Expands to full available width |
| icon | Widget? | no | null | Leading icon shown before the label |

`AppButtonVariant { primary, ghost, danger, accent }` · `AppButtonSize { md, sm }`.

## Visual States

| State | Appearance |
|-------|------------|
| primary | surface-2 bg, text-1, 1px border, radius md |
| accent | accent bg, onAccent text, no border; pressed → accentDim |
| ghost | transparent bg, text-2, 1px border |
| danger | transparent bg, danger text, 1px danger border |
| disabled (onPressed null) | opacity 0.4, no tap response |
| sizes | md: min-height 48, padding 0×20, text base/600 · sm: min-height 36, padding 0×12, text sm |

## Accessibility
- Semantic label: the `label` text
- Minimum touch target: 36–48 dp height per size

## Acceptance Criteria
- AC-001: Widget renders the label
- AC-002: Widget calls onPressed when tapped and onPressed is non-null
- AC-003: Widget does not call onPressed and renders at reduced opacity when onPressed is null
- AC-004: Widget renders a leading icon before the label when an icon is provided
