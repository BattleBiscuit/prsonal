---
name: Body
type: screen
status: approved
---

## Description
Log and review body measurements (Body tab, route `/body`). A 2-column grid of metric cards for the
six metric types, followed by per-metric history lists. Tapping a card opens a bottom-sheet to log
a value; history entries can be deleted.

## Layout

```
┌───────────────────────────────────────┐
│ PRsonal · Body                        │
├───────────────────────────────────────┤
│ [Bodyweight 82.5kg +] [Body fat — +]  │
│ [Waist 88cm +]        [Chest — +]     │
│ [Arms — +]            [Legs — +]      │
│ BODYWEIGHT HISTORY                    │
│ Jun 23 · 82.5 kg                  ✕   │
└───────────────────────────────────────┘
```

## Widgets used

| Widget | Spec |
|--------|------|
| AppPageShell · AppModal · AppButton | shared |
| BodyMetricCard | `widgets/body_metric_card.md` |

## State dependencies
- `bodyLatestProvider` / `bodyServiceProvider` — latest per type + per-type history

## Acceptance Criteria
- AC-001: Renders a metric card for each of the six body metric types
- AC-002: A metric card shows the latest value or a dash when none has been logged
- AC-003: Tapping a metric card opens a log sheet for that metric
- AC-004: Submitting the log sheet records a new value
- AC-005: Renders a history list for metrics that have entries
- AC-006: Deleting a history entry removes it
