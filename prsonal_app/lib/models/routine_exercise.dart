// RoutineExercise / SetTarget model — pure Dart, no Flutter/Drift imports.

import 'package:prsonal_app/models/exercise.dart';

/// Immutable value object representing the planned target for a single set.
///
/// Stored as JSON in the `routineExercises.sets` column.
class SetTarget {
  const SetTarget._({
    required this.kind,
    this.reps,
    this.weight,
    this.isBodyweight,
    this.restSeconds,
    this.duration,
    this.level,
  });

  /// Creates a default strength set target.
  factory SetTarget.strength({
    int reps = 10,
    double weight = 0,
    bool isBodyweight = false,
    int restSeconds = 90,
  }) {
    return SetTarget._(
      kind: ExerciseType.strength,
      reps: reps,
      weight: weight,
      isBodyweight: isBodyweight,
      restSeconds: restSeconds,
    );
  }

  /// Creates a default cardio set target.
  factory SetTarget.cardio({
    int duration = 20,
    int level = 1,
    int restSeconds = 0,
  }) {
    return SetTarget._(
      kind: ExerciseType.cardio,
      duration: duration,
      level: level,
      restSeconds: restSeconds,
    );
  }

  /// Deserialises from a JSON map (as stored in the database).
  factory SetTarget.fromJson(Map<String, dynamic> json) {
    final kind = ExerciseType.values.byName(json['kind'] as String);
    if (kind == ExerciseType.strength) {
      return SetTarget._(
        kind: ExerciseType.strength,
        reps: (json['reps'] as num?)?.toInt(),
        weight: (json['weight'] as num?)?.toDouble(),
        isBodyweight: json['isBodyweight'] as bool?,
        restSeconds: (json['restSeconds'] as num?)?.toInt(),
      );
    } else {
      return SetTarget._(
        kind: ExerciseType.cardio,
        duration: (json['duration'] as num?)?.toInt(),
        level: (json['level'] as num?)?.toInt(),
        restSeconds: (json['restSeconds'] as num?)?.toInt(),
      );
    }
  }

  final ExerciseType kind;

  // Strength fields
  final int? reps;
  final double? weight;
  final bool? isBodyweight;
  final int? restSeconds;

  // Cardio fields
  final int? duration;
  final int? level;

  bool get isCardio => kind == ExerciseType.cardio;

  /// Serialises to a JSON map for database storage.
  Map<String, dynamic> toJson() {
    if (kind == ExerciseType.strength) {
      return {
        'kind': kind.name,
        'reps': reps,
        'weight': weight,
        'isBodyweight': isBodyweight,
        'restSeconds': restSeconds,
      };
    } else {
      return {
        'kind': kind.name,
        'duration': duration,
        'level': level,
        'restSeconds': restSeconds,
      };
    }
  }

  /// Returns a copy with the specified fields replaced.
  SetTarget copyWith({
    int? reps,
    double? weight,
    bool? isBodyweight,
    int? restSeconds,
    int? duration,
    int? level,
  }) {
    return SetTarget._(
      kind: kind,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
      isBodyweight: isBodyweight ?? this.isBodyweight,
      restSeconds: restSeconds ?? this.restSeconds,
      duration: duration ?? this.duration,
      level: level ?? this.level,
    );
  }
}

/// Returns true when [sets] contains at least one element.
bool validateSets(List<SetTarget> sets) => sets.isNotEmpty;
