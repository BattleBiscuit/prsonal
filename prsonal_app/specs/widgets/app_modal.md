---
name: AppModal
type: widget
status: approved
---

## Description
The app's bottom-sheet modal, ported from gym-app's `AppModal`. A `surface-1` card anchored to the
bottom of the screen with top corners rounded (radius xl), an optional title header with a close
button, a body, and an optional stacked actions footer. Presented over a `black@0.70` scrim and
slid up over 200ms. Used for confirmations (finish/abandon/delete), pickers (exercise/routine
search), and forms (exercise editor, body logging, backup options).

`AppModal` is the sheet **content**; it is shown via a helper `showAppModal(context, ...)` that
wraps Flutter's `showModalBottomSheet` with the correct scrim, shape, and slide transition.

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| title | String? | no | null | Header title; header is omitted when null |
| child | Widget | yes | — | Body content |
| actions | List\<Widget\>? | no | null | Footer buttons, stacked full-width |
| onClose | VoidCallback? | no | null | Called when the close button is tapped |

## Visual States

| State | Appearance |
|-------|------------|
| with title | header row: title (lg/600) + 32dp circular close button (✕); 1px bottom border |
| without title | no header; body starts at the top |
| with actions | footer column of full-width buttons, gap 8, 1px top border |

## Accessibility
- Close button semantic label: "Close"
- Scrim tap dismisses (when presented via showAppModal with isDismissible)

## Acceptance Criteria
- AC-001: Widget renders the title when provided
- AC-002: Widget renders the body child
- AC-003: Widget renders the actions when provided
- AC-004: Widget calls onClose when the close button is tapped
- AC-005: Widget omits the header when no title is provided
