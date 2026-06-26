---
name: ChartSlider
type: widget
status: approved
---

## Description
A horizontally swipeable container hosting the Progress charts, ported from gym-app's
`ChartSlider`. Shows one page at a time with a row of pagination dots below; swiping or tapping a
dot changes page.

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| pages | List\<Widget\> | yes | — | The chart pages (e.g. radar, volume) |
| titles | List\<String\> | yes | — | Per-page header titles |

## Acceptance Criteria
- AC-001: Widget renders the first page and its title
- AC-002: Widget renders one pagination dot per page
- AC-003: Swiping advances to the next page
- AC-004: Tapping a pagination dot jumps to that page
