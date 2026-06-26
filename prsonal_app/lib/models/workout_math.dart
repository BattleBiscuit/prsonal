// Workout math helpers — pure Dart, no Flutter/Drift imports.

/// Returns bodyweight + [actualWeight] when [isBodyweight] is true,
/// otherwise returns [actualWeight] unchanged.
double resolveEffectiveWeight({
  required bool isBodyweight,
  required double actualWeight,
  required double bodyweight,
}) {
  if (isBodyweight) return bodyweight + actualWeight;
  return actualWeight;
}

/// Epley estimated one-rep max.
/// Returns [effectiveWeight] unchanged when [reps] is 1.
double estimatedOneRepMax({
  required double effectiveWeight,
  required int reps,
}) {
  if (reps == 1) return effectiveWeight;
  return effectiveWeight * (1 + reps / 30);
}

/// Returns true when [candidateOneRepMax] strictly exceeds [bestOneRepMax].
bool isNewPR({
  required double candidateOneRepMax,
  required double bestOneRepMax,
}) {
  return candidateOneRepMax > bestOneRepMax;
}

/// Formats a weight value for display.
///
/// - Bodyweight + 0 added  → "BW"
/// - Bodyweight + positive → "BW+{n}kg"
/// - Bodyweight + negative → "BW-{n}kg"  (sign is already in [weight])
/// - Regular               → "{n}kg"
String formatWeight(num weight, {bool isBodyweight = false}) {
  if (isBodyweight) {
    if (weight == 0) return 'BW';
    final sign = weight > 0 ? '+' : '';
    final formatted = _formatNum(weight);
    return 'BW$sign${formatted}kg';
  }
  return '${_formatNum(weight)}kg';
}

/// Formats a volume value with thousands separator and " kg" suffix.
/// e.g. 4230 → "4,230 kg"
String formatVolume(num volume) {
  final intVal = volume.round();
  final parts = <String>[];
  var remaining = intVal.abs();
  if (remaining == 0) {
    return '0 kg';
  }
  while (remaining > 0) {
    final chunk = remaining % 1000;
    remaining = remaining ~/ 1000;
    if (remaining > 0) {
      parts.add(chunk.toString().padLeft(3, '0'));
    } else {
      parts.add(chunk.toString());
    }
  }
  final sign = intVal < 0 ? '-' : '';
  return '$sign${parts.reversed.join(',')} kg';
}

String _formatNum(num value) {
  // Strip trailing decimal zeros for whole numbers.
  if (value == value.truncate()) {
    return value.truncate().toString();
  }
  return value.toString();
}
