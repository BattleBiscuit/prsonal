// Exercise model — pure Dart, no Flutter/Drift imports.

enum ExerciseType { strength, cardio }

enum Muscle {
  chest,
  shoulders,
  arms,
  back,
  core,
  legs,
  glutes;

  String get label {
    switch (this) {
      case Muscle.chest:
        return 'Chest';
      case Muscle.shoulders:
        return 'Shoulders';
      case Muscle.arms:
        return 'Arms';
      case Muscle.back:
        return 'Back';
      case Muscle.core:
        return 'Core';
      case Muscle.legs:
        return 'Legs';
      case Muscle.glutes:
        return 'Glutes';
    }
  }
}

/// Returns true when [name] is non-empty after trimming whitespace.
bool validateExerciseName(String name) => name.trim().isNotEmpty;
