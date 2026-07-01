import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../models/routine_exercise.dart';
import '../app_database.dart';

/// Routine + routine-exercise queries. Kept as extension methods on
/// [AppDatabase] (rather than a `@DriftAccessor` DAO class) so call sites
/// keep the same `db.method()` surface used throughout the app's services.
extension RoutinesDao on AppDatabase {
  static final _uuid = Uuid();

  /// Inserts a routine with a generated UUID and returns the id.
  Future<String> insertRoutine({required String name, String? notes}) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    await into(routines).insert(
      RoutinesCompanion.insert(
        id: id,
        name: name,
        notes: Value(notes),
        createdAt: now,
        updatedAt: now,
      ),
    );
    return id;
  }

  /// Returns a stream of all routines ordered by updatedAt descending.
  Stream<List<Routine>> watchAllRoutines() {
    return (select(
      routines,
    )..orderBy([(r) => OrderingTerm.desc(r.updatedAt)])).watch();
  }

  /// Returns a single routine by id, or null.
  Future<Routine?> routineById(String id) {
    return (select(routines)..where((r) => r.id.equals(id))).getSingleOrNull();
  }

  /// Returns all exercises for a routine in position order.
  Future<List<RoutineExercise>> routineExercisesForRoutine(String routineId) {
    return (select(routineExercises)
          ..where((re) => re.routineId.equals(routineId))
          ..orderBy([(re) => OrderingTerm.asc(re.position)]))
        .get();
  }

  /// Inserts a routine row.
  Future<void> insertRoutineRow(RoutinesCompanion row) =>
      into(routines).insert(row);

  /// Updates a routine row.
  Future<bool> updateRoutineRow(RoutinesCompanion row) =>
      update(routines).replace(row);

  /// Deletes a routine by id.
  Future<int> deleteRoutineById(String id) =>
      (delete(routines)..where((r) => r.id.equals(id))).go();

  /// Returns the planned [SetTarget]s for every exercise in [routineId], in
  /// position order. Used by the session engine to write progressive-overload
  /// targets back after finishing a session.
  Future<List<SetTarget>> setTargetsForRoutine(String routineId) async {
    final rows =
        await (select(routineExercises)
              ..where((re) => re.routineId.equals(routineId))
              ..orderBy([(re) => OrderingTerm.asc(re.position)]))
            .get();
    return rows.expand((re) => re.sets).toList();
  }

  // ---------------------------------------------------------------------------
  // RoutineExercise queries
  // ---------------------------------------------------------------------------

  /// Inserts a routine exercise row.
  Future<void> insertRoutineExerciseRow(RoutineExercisesCompanion row) =>
      into(routineExercises).insert(row);

  /// Updates a routine exercise row.
  Future<bool> updateRoutineExerciseRow(RoutineExercisesCompanion row) =>
      update(routineExercises).replace(row);

  /// Deletes a single routine exercise by id.
  Future<int> deleteRoutineExerciseById(String id) =>
      (delete(routineExercises)..where((re) => re.id.equals(id))).go();

  /// Deletes all routine exercises for a routine.
  Future<int> deleteRoutineExercisesForRoutine(String routineId) => (delete(
    routineExercises,
  )..where((re) => re.routineId.equals(routineId))).go();

  // ---------------------------------------------------------------------------
  // Bulk export / import (used by BackupService)
  // ---------------------------------------------------------------------------

  Future<List<Routine>> allRoutines() => select(routines).get();
  Future<List<RoutineExercise>> allRoutineExercises() =>
      select(routineExercises).get();

  Future<void> clearRoutines() => delete(routines).go();
  Future<void> clearRoutineExercises() => delete(routineExercises).go();

  Future<void> bulkInsertRoutines(List<RoutinesCompanion> rows) async {
    await batch((b) => b.insertAll(routines, rows));
  }

  Future<void> bulkInsertRoutineExercises(
    List<RoutineExercisesCompanion> rows,
  ) async {
    await batch((b) => b.insertAll(routineExercises, rows));
  }
}
