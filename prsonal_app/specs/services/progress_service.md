---
name: ProgressService
type: service
status: approved
---

## Description
Read-only analytics over the workout history, powering the Progress screen and All-PRs list. All
figures derive from [[workout_session]] / [[workout_set]] joined to [[exercise]], using the stored
Epley `estimated1RM` for every PR/ranking calculation (the single source established in
[[architecture]]). Each method takes a `rangeDays` (or `asOf`) so results are deterministic and
testable; streak/adherence reuse [[plans_service]] semantics.

View model: `PRItem { exerciseName, oneRepMax, reps, weight, isBodyweight, date }`.

## Methods

| Method | Inputs | Output |
|--------|--------|--------|
| workoutCount | `int rangeDays, {DateTime asOf}` | `Future<int>` |
| sessionVolumes | `int rangeDays, {DateTime asOf}` | `Future<List<({String label, double volume, String routineName})>>` |
| volumeTrendPercent | `int rangeDays, {DateTime asOf}` | `Future<double?>` |
| muscleFrequency | `int rangeDays, MuscleMode mode, {DateTime asOf}` | `Future<List<({Muscle muscle, double count})>>` |
| recentPRs | `int rangeDays, {DateTime asOf}` | `Future<List<PRItem>>` |
| allPRs | — | `Future<List<PRItem>>` |
| bestLifts | `{int limit}` | `Future<List<PRItem>>` |
| planAdherencePercent | `int rangeDays, {DateTime asOf}` | `Future<double?>` |

`MuscleMode { exercise, session }` — exercise mode dedupes a muscle once per exercise; session
mode once per session. Primary muscles count 1.0, secondary 0.5.

## Acceptance Criteria
- AC-001: workoutCount returns the number of completed sessions started within the range
- AC-002: sessionVolumes returns one entry per completed session with its summed volume (actualReps × effectiveWeight)
- AC-003: volumeTrendPercent returns the percent change between the first and second half of the range, or null when there is too little data
- AC-004: muscleFrequency counts primary muscles at 1.0 and secondary at 0.5, joined from the exercise library
- AC-005: allPRs returns the single best set per exercise ranked by estimated 1RM
- AC-006: recentPRs returns PR sets within the range, newest first
- AC-007: bestLifts returns the top lifts by estimated 1RM, limited to the requested count
- AC-008: planAdherencePercent returns the completed-versus-required percentage for active plans in the range
