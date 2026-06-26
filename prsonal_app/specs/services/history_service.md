---
name: HistoryService
type: service
status: approved
---

## Description
Reads and edits completed workout history. Provides paged summaries for the History list, full
detail (sets grouped by exercise) for the detail screen, deletion, and inline editing of logged
actuals. Volume is computed from sets on read (no stored total); a completed session with zero
volume is reported as abandoned (see [[workout_session]]).

View models: `SessionSummary { id, routineName, startedAt, durationLabel, volume, abandoned }`,
`SessionDetail { id, routineName, startedAt, durationLabel, volume, abandoned, exercises, prNames }`,
`DetailExercise { name, sets }`.

## Methods

| Method | Inputs | Output | Side Effects |
|--------|--------|--------|--------------|
| count | — | `Future<int>` | none — number of completed sessions |
| loadPage | `{int page, int pageSize}` | `Future<List<SessionSummary>>` | none — newest first, paged |
| getDetail | `String id` | `Future<SessionDetail>` | none — sets grouped by exercise in position order |
| deleteSession | `String id` | `Future<void>` | deletes the session and its sets |
| updateSetActuals | `String setId, {int? reps, double? weight, bool? isBodyweight, bool? skipped}` | `Future<void>` | persists edits and recomputes effectiveWeight + estimated1RM |

## Error Cases
- `getDetail` throws `NotFoundException` for an unknown id.

## Acceptance Criteria
- AC-001: count returns the number of completed sessions
- AC-002: loadPage returns completed sessions newest first, paged by pageSize
- AC-003: getDetail returns the session with its sets grouped by exercise in position order
- AC-004: getDetail reports the names of exercises that set a personal record in the session
- AC-005: deleteSession removes the session and all of its sets
- AC-006: updateSetActuals persists edited reps and weight and recomputes effectiveWeight and estimated1RM
- AC-007: a completed session with zero logged volume is reported as abandoned
