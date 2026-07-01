---
name: SessionService
type: service
status: approved
---

## Description
The workout engine — the single owner of an in-progress session. Implemented as a Riverpod
`Notifier` exposed by `sessionEngineProvider` whose state is an `ActiveSessionState?` (null when no
workout is running). It coordinates the Drift database ([[workout_session]], [[workout_set]]) and
the [[PlatformService]], and applies the pure [[workout_math]] for effective weight, Epley 1RM, and
PR detection.

This consolidates gym-app's `useSessionStore` + `useSessionRunner` + `useRestTimer` into one
testable engine. Navigation timers (elapsed clock, rest countdown) are ephemeral state on the
notifier, never persisted (a deliberate simplification over gym-app, which stored timer fields in
the persistence layer).

`activeSessionProvider` (bool, consumed by AppBottomNav / AppPageShell) is derived as
`ref.watch(sessionEngineProvider) != null`.

### ActiveSessionState (runtime, not persisted)
`session` (WorkoutSession) · `exercises` (ordered slots, each with its `WorkoutSet`s) · `cursor`
(`exerciseIndex`, `setIndex`) · derived getters `completedCount`, `totalCount`, `progress`
(0–1), `isLastSet`, `currentSet` · timer fields `elapsed`, `resting`, `restRemaining`,
`restTotal`.

## Methods

| Method | Inputs | Output | Side Effects |
|--------|--------|--------|--------------|
| startSession | `{String routineId, String? planId, String? planEntryId}` | `Future<void>` | inserts a session + one WorkoutSet per planned set; cursor → first set; wakelock on |
| resumeActiveSession | — | `Future<bool>` | if a session with status `active` exists, rebuilds state with cursor at the first incomplete set; returns whether one was found |
| markCurrentSetComplete | `{num actualPrimary, num actualSecondary, bool isBodyweight}` | `Future<bool>` | freezes `effectiveWeight` + `estimated1RM`, sets `completedAt`, computes `isPR`; haptic (PR vs tap); advances cursor; starts rest if `restSeconds > 0`; returns whether it was a PR |
| skipCurrentSet | — | `Future<void>` | marks `skipped`, advances cursor |
| jumpToSet | `int exerciseIndex, int setIndex` | `void` | moves the cursor; makes the target the only active set (reverting the previously active set to pending); cancels any active rest |
| uncheckSet | `int exerciseIndex, int setIndex` | `Future<void>` | clears completion/skip on a logged set and selects it |
| addExerciseToSession | `{String exerciseId, List<SetTarget> sets}` | `Future<void>` | appends an exercise + its sets to the live session |
| skipAllRemaining | — | `Future<void>` | marks every not-yet-logged set `skipped` |
| finishSession | — | `Future<void>` | sets status `completed` + `completedAt`; writes each exercise's logged actuals back to the routine as new planned targets; wakelock off; state → null |
| abandonSession | — | `Future<void>` | deletes the session and all its sets; wakelock off; state → null |
| startRest | `int seconds` | `void` | begins the rest countdown and schedules the rest-complete notification |
| cancelRest | — | `void` | stops the countdown and cancels the notification |

## PR detection
On `markCurrentSetComplete` for a strength set: `effectiveWeight =
resolveEffectiveWeight(...)`, `estimated1RM = estimatedOneRepMax(...)`. The set `isPR` when its
`estimated1RM` is strictly greater than the max `estimated1RM` of every prior completed,
non-skipped, strength set of the **same exercise** (matched by `exerciseId`, else `exerciseName`),
across all sessions and earlier in this session. Cardio sets are never PRs. Bodyweight resolution
uses the derived bodyweight (latest `weight` body metric, default 80 kg).

## Error Cases
- Throws `StateError` when a mutating method is called with no active session.
- `startSession` throws `ArgumentError` when the routine does not exist or has no exercises.

## Acceptance Criteria
- AC-001: startSession creates an active session and one workout set per planned set of the routine, with the cursor on the first set
- AC-002: resumeActiveSession restores an existing active session with the cursor at the first incomplete set, and returns false when none exists
- AC-003: markCurrentSetComplete records the actual reps and weight, sets completedAt, and freezes effectiveWeight and estimated1RM
- AC-004: a completed strength set whose estimated 1RM exceeds every prior set of that exercise is flagged isPR
- AC-005: a completed strength set whose estimated 1RM does not exceed the prior best is not flagged isPR
- AC-006: markCurrentSetComplete advances the cursor to the next set
- AC-007: completing a PR set triggers a PR haptic and a non-PR set triggers a tap haptic
- AC-008: finishSession marks the session completed and writes the logged actuals back to the routine as new planned targets
- AC-009: abandonSession deletes the session and all of its sets and clears the active state
- AC-010: startRest schedules a rest-complete notification and cancelRest cancels it
- AC-011: a mutating method called with no active session throws a StateError
- AC-012: jumpToSet makes the selected set the only active set, reverting any previously active set to pending
- AC-013: uncheckSet clears a completed set's completion and selects it as the active editable set (cursor moves to it)
- AC-014: completing a set marked bodyweight stores effectiveWeight = bodyweight + the entered (signed) added weight and persists the bodyweight flag on the set
