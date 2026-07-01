---
name: BrandTitle
type: widget
status: approved
---

## Description
The app-bar title used across chrome screens: the brand mark, the "PRsonal" wordmark ("PR" in
`text1`, "sonal" in `accent`, per [[design_system]]'s "brand wordmark 13/700"), a "·" divider, and
the page title.

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| title | String | yes | — | Page title shown after the wordmark |

## Visual States

| State | Appearance |
|-------|------------|
| default | brand mark · "PR" (text1/700) + "sonal" (accent/700), 13sp · " · " (text3) · title (text1, 16/600) |

## Accessibility
- Wordmark semantic label: "PRsonal"

## Acceptance Criteria
- AC-001: Widget renders the page title
- AC-002: Widget renders the "sonal" portion of the wordmark in the accent colour
