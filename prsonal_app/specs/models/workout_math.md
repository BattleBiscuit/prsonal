---
name: WorkoutMath
type: model
status: approved
---

## Description
The pure, dependency-free calculations shared across the workout, progress, and history
features: resolving the effective load of a set, estimating a one-rep max, deciding whether a set
is a personal record, and formatting weights and volumes for display. These live in
`lib/models/workout_math.dart` as top-level functions so every layer computes them identically
(this is the single source that removes gym-app's peak-weight-vs-Epley PR inconsistency).

All weights are kilograms.

## Functions

| Function | Inputs | Output | Notes |
|----------|--------|--------|-------|
| resolveEffectiveWeight | `{bool isBodyweight, double actualWeight, double bodyweight}` | `double` | bodyweight-relative sets add the user's bodyweight |
| estimatedOneRepMax | `{double effectiveWeight, int reps}` | `double` | Epley: 1 rep = raw; else `w·(1 + reps/30)` |
| isNewPR | `{double candidateOneRepMax, double bestOneRepMax}` | `bool` | strictly greater |
| formatWeight | `double weight, {bool isBodyweight = false}` | `String` | "BW", "BW+10kg", "BW-10kg", "75kg" |
| formatVolume | `double kilograms` | `String` | thousands-grouped + " kg" |

## Acceptance Criteria
- AC-001: resolveEffectiveWeight returns the actual weight unchanged when the set is not bodyweight-relative
- AC-002: resolveEffectiveWeight returns bodyweight plus the actual weight when the set is bodyweight-relative
- AC-003: estimatedOneRepMax returns the effective weight unchanged when reps equals 1
- AC-004: estimatedOneRepMax applies the Epley formula weight × (1 + reps / 30) when reps is greater than 1
- AC-005: isNewPR is true only when the candidate one-rep max strictly exceeds the previous best
- AC-006: formatWeight returns "BW" for a bodyweight set with zero added weight
- AC-007: formatWeight returns "BW+10kg" and "BW-10kg" for bodyweight sets with added or removed weight
- AC-008: formatWeight returns "75kg" for a normal weighted set
- AC-009: formatVolume groups thousands and appends " kg"
