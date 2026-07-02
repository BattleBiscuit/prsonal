/// Thrown when a requested resource does not exist in the database.
class NotFoundException implements Exception {
  const NotFoundException([this.message]);

  final String? message;

  @override
  String toString() {
    if (message != null) return 'NotFoundException: $message';
    return 'NotFoundException';
  }
}

/// Thrown when a backup document cannot be parsed or applied.
class BackupException implements Exception {
  const BackupException(this.message);

  final String message;

  @override
  String toString() => 'BackupException: $message';
}

/// Thrown when deleting an exercise that a routine still references
/// (`RoutineExercises.exerciseId` is `onDelete: restrict`).
class ExerciseInUseException implements Exception {
  const ExerciseInUseException();

  @override
  String toString() =>
      'ExerciseInUseException: exercise is still used by a routine';
}
