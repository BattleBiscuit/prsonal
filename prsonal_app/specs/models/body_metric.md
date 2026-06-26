---
name: BodyMetric
type: model
status: approved
---

## Description
A single logged body measurement — a value of a given type at a point in time. Backed by the
Drift table `bodyMetrics`. Powers the Body screen's metric cards and history lists. The latest
`weight` metric also supplies the app's working bodyweight (used to resolve bodyweight-relative
sets); when none is logged, bodyweight defaults to 80 kg.

## Fields

| Field | Type | Nullable | Default | Validation |
|-------|------|----------|---------|------------|
| id | String | no | uuid v4 | non-empty |
| type | BodyMetricType | no | — | one of the six types |
| value | double | no | — | > 0 |
| loggedAt | DateTime | no | now | — |

`BodyMetricType { weight, bodyfat, waist, chest, arms, legs }`.

## Relationships
- Standalone (no foreign keys)

## Acceptance Criteria
- AC-001: BodyMetricType exposes exactly six types: weight, bodyfat, waist, chest, arms, legs
- AC-002: BodyMetricType.unit returns "kg" for weight, "%" for bodyfat, and "cm" for waist, chest, arms and legs
- AC-003: BodyMetricType.label returns the display label (Bodyweight, Body fat, Waist, Chest, Arms, Legs)
- AC-004: validateBodyMetricValue returns false for a value of zero or less and true for a positive value
- AC-005: BodyMetricType resolves from its stored name; an unknown name throws
