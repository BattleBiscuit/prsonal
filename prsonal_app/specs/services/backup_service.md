---
name: BackupService
type: service
status: approved
---

## Description
Exports and restores app data as a JSON document — the one optional feature kept from gym-app.
Operates on selectable sections (library, routines, plans, history) so the user can back up or
restore a subset. Restoring a section replaces its current contents. Exposed via
`backupServiceProvider`.

`BackupSection { library, routines, plans, history }`.

## Methods

| Method | Inputs | Output | Side Effects |
|--------|--------|--------|--------------|
| counts | — | `Future<Map<BackupSection, int>>` | none — records available per section |
| exportJson | `{Set<BackupSection> sections}` | `Future<String>` | serializes the selected sections |
| importJson | `String json, {Set<BackupSection> sections}` | `Future<void>` | replaces the selected sections with the document's data |

## Error Cases
- `importJson` throws `FormatException` when the JSON is malformed or not a recognised backup.

## Acceptance Criteria
- AC-001: exportJson serializes the selected sections to a JSON document
- AC-002: importJson replaces the selected sections with the document's contents
- AC-003: an export followed by an import into an empty database reproduces the data
- AC-004: counts returns the number of records available per section
- AC-005: importJson throws a FormatException for malformed input
