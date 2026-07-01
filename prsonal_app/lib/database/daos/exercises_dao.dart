import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../models/exercise.dart';
import '../app_database.dart';

/// Exercise-library queries. Kept as extension methods on [AppDatabase]
/// (rather than a `@DriftAccessor` DAO class) so call sites keep the same
/// `db.method()` surface used throughout the app's services.
extension ExercisesDao on AppDatabase {
  static final _uuid = Uuid();

  /// Inserts an exercise with a generated UUID and returns the id.
  Future<String> insertExercise({
    required String name,
    required ExerciseType type,
    List<Muscle> primaryMuscles = const [],
    List<Muscle> secondaryMuscles = const [],
    String? notes,
  }) async {
    final id = _uuid.v4();
    await into(exercises).insert(
      ExercisesCompanion.insert(
        id: id,
        name: name,
        type: type,
        primaryMuscles: Value(primaryMuscles),
        secondaryMuscles: Value(secondaryMuscles),
        notes: Value(notes),
        createdAt: DateTime.now(),
      ),
    );
    return id;
  }

  /// Inserts an exercise with an explicit [id].
  Future<void> insertExerciseWithId(
    String id, {
    required String name,
    required ExerciseType type,
    List<Muscle> primaryMuscles = const [],
    List<Muscle> secondaryMuscles = const [],
    String? notes,
  }) async {
    await into(exercises).insert(
      ExercisesCompanion.insert(
        id: id,
        name: name,
        type: type,
        primaryMuscles: Value(primaryMuscles),
        secondaryMuscles: Value(secondaryMuscles),
        notes: Value(notes),
        createdAt: DateTime.now(),
      ),
    );
  }

  /// Returns a stream of all exercises ordered alphabetically by name.
  Stream<List<Exercise>> watchAllExercises() {
    return (select(
      exercises,
    )..orderBy([(e) => OrderingTerm.asc(e.name)])).watch();
  }

  /// Returns all exercises with name matching [query] (case-insensitive).
  Future<List<Exercise>> searchExercises(String query) {
    final pattern = '%${query.toLowerCase()}%';
    return (select(exercises)
          ..where((e) => e.name.lower().like(pattern))
          ..orderBy([(e) => OrderingTerm.asc(e.name)]))
        .get();
  }

  /// Returns a single exercise by id, or null.
  Future<Exercise?> exerciseById(String id) {
    return (select(exercises)..where((e) => e.id.equals(id))).getSingleOrNull();
  }

  /// Inserts an exercise row using the provided companion.
  Future<void> insertExerciseRow(ExercisesCompanion row) =>
      into(exercises).insert(row);

  /// Updates an exercise row.
  Future<bool> updateExerciseRow(ExercisesCompanion row) =>
      update(exercises).replace(row);

  /// Deletes an exercise by id.
  Future<int> deleteExerciseById(String id) =>
      (delete(exercises)..where((e) => e.id.equals(id))).go();

  // ---------------------------------------------------------------------------
  // Bulk export / import (used by BackupService)
  // ---------------------------------------------------------------------------

  /// Returns all rows from the table as a list. Used by BackupService.
  Future<List<Exercise>> allExercises() => select(exercises).get();

  /// Clears all rows from the table. Used by BackupService before re-import.
  Future<void> clearExercises() => delete(exercises).go();

  /// Bulk-inserts exercise rows (for restore).
  Future<void> bulkInsertExercises(List<ExercisesCompanion> rows) async {
    await batch((b) => b.insertAll(exercises, rows));
  }
}
