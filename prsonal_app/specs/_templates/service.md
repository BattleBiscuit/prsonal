---
name: <ServiceName>
type: service
status: draft
---

## Description
One paragraph describing what this service is responsible for (data access, business logic, external API, etc.).

## Methods

| Method | Inputs | Output | Side Effects |
|--------|--------|--------|--------------|
| getAll | — | `Future<List<T>>` | none |
| getById | `String id` | `Future<T?>` | none |
| save | `T item` | `Future<void>` | persists item |
| delete | `String id` | `Future<void>` | removes item |

## Error Cases
- Throws `NotFoundException` when item with given id does not exist
- Throws `ValidationException` when input fails validation

## Acceptance Criteria
- AC-001: [method] returns [result] when [condition]
- AC-002: [method] throws [exception] when [condition]
