// WorkoutSet model — pure Dart, no Flutter/Drift imports.

import 'package:prsonal_app/models/exercise.dart';
import 'package:prsonal_app/models/workout_math.dart';

/// Returns true when the set has a [completedAt] timestamp and is not skipped.
bool workoutSetIsComplete({
  required DateTime? completedAt,
  required bool skipped,
}) {
  return completedAt != null && !skipped;
}

/// Formats a strength set for display, e.g. "10×80kg" or "10×BW+10kg".
String formatStrengthSet({
  required int reps,
  required num weight,
  required bool isBodyweight,
}) {
  return '$reps×${formatWeight(weight, isBodyweight: isBodyweight)}';
}

/// Formats a cardio set for display, e.g. "30min · lvl5".
String formatCardioSet({required int duration, required int level}) {
  return '${duration}min · lvl$level';
}

/// Returns the Epley estimated one-rep max for a completed strength set,
/// or null for cardio sets.
double? setEstimatedOneRepMax({
  required ExerciseType type,
  required double? effectiveWeight,
  required int? actualReps,
}) {
  if (type == ExerciseType.cardio) return null;
  if (effectiveWeight == null || actualReps == null) return null;
  return estimatedOneRepMax(effectiveWeight: effectiveWeight, reps: actualReps);
}
