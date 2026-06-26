---
name: <ModelName>
type: model
status: draft
---

## Description
One paragraph describing what this model represents and its role in the app.

## Fields

| Field | Type | Nullable | Default | Validation |
|-------|------|----------|---------|------------|
| id | String | no | — | non-empty UUID |
| createdAt | DateTime | no | now | must be in the past or present |

## Relationships
- Belongs to: —
- Has many: —

## Acceptance Criteria
- AC-001: [field] must [constraint]
- AC-002: [field] must [constraint]
