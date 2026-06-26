---
name: SettingsRow
type: widget
status: approved
---

## Description
A single row in a Settings section, ported from gym-app's settings rows. A title with an optional
subtitle and an optional trailing widget (icon or control). Tappable when `onTap` is provided.

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| title | String | yes | — | Row title |
| subtitle | String? | no | null | Secondary line |
| trailing | Widget? | no | null | Trailing icon/control |
| onTap | VoidCallback? | no | null | Tap handler; inert when null |

## Acceptance Criteria
- AC-001: Widget renders the title and subtitle
- AC-002: Widget renders a trailing widget when provided
- AC-003: Widget calls onTap when tapped and onTap is non-null
