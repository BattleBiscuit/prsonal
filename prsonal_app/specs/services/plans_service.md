---
name: PlansService
type: service
status: approved
---

## Description
CRUD for [[plan]] and [[plan_entry]], plus the read-models that drive the Workout (session-pick)
screen: the active-plans view (entries with resolved routine names, day labels, done-this-week
flags, and a streak) and the list of unplanned routines. Routine names and day labels are derived
by joining [[routine]] (not stored). Time-dependent calculations take an `asOf` argument for
deterministic testing; the providers supply `nowProvider`.

View models (exported for `session_pick_providers`): `PlanView { id, name, streak, entries }`,
`PlanEntryView { entryId, routineId, routineName, dayLabel, doneThisWeek }`,
`UnplannedRoutine { id, name }`, `PlanDraft { id, name, entries }`.

## Methods

| Method | Inputs | Output | Side Effects |
|--------|--------|--------|--------------|
| watchPlans | — | `Stream<List<Plan>>` | none — active plans by order |
| getPlanForEdit | `String id` | `Future<PlanDraft>` | none — plan + entries (routine names resolved) in order |
| createPlan | `String name` | `Future<String>` | inserts an active plan at the next order; returns id |
| updatePlan | `String id, {String? name, PlanStatus? status}` | `Future<void>` | updates fields |
| deletePlan | `String id` | `Future<void>` | deletes plan + entries |
| replaceEntries | `String planId, List<PlanEntryInput> entries` | `Future<void>` | deletes existing entries and re-inserts the given ones in order |
| activePlansView | `{required DateTime asOf}` | `Future<List<PlanView>>` | none — active plans with entries, day labels, done-this-week, streak |
| unplannedRoutines | — | `Future<List<UnplannedRoutine>>` | none — routines not referenced by any active plan |
| streakForPlan | `String planId, {required DateTime asOf}` | `Future<int>` | none |

## Streak definition
Counting back from the week containing `asOf`: a week is "complete" when every entry with a
non-null `dayOfWeek` has a completed session referencing that `planEntryId` within the week. The
current week only requires entries whose `dayOfWeek` ≤ `asOf`'s weekday. The streak is the number
of consecutive complete weeks; it stops at the first incomplete week.

## Error Cases
- `getPlanForEdit` throws `NotFoundException` for an unknown id.

## Acceptance Criteria
- AC-001: createPlan inserts an active plan and returns its id
- AC-002: getPlanForEdit returns the plan with its entries, routine names resolved, in order
- AC-003: replaceEntries replaces all of a plan's entries with the supplied set
- AC-004: deletePlan removes the plan and all of its entries
- AC-005: activePlansView returns only active plans, each with its entries and day labels
- AC-006: an entry is marked done-this-week when a completed session references that entry within the asOf week
- AC-007: unplannedRoutines lists only routines not referenced by any active plan
- AC-008: streakForPlan counts the consecutive complete weeks ending at the asOf week
