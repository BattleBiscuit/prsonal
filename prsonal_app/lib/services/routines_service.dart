import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../models/routine_exercise.dart';
import '../providers/app_providers.dart';
import 'service_exceptions.dart';

export 'service_exceptions.dart' show NotFoundException;

// ---------------------------------------------------------------------------
// View-model types
// ---------------------------------------------------------------------------

/// Lightweight summary shown in a list — one row per routine.
class RoutineSummary {
  const RoutineSummary({
    required this.id,
    required this.name,
    this.notes,
    required this.exerciseCount,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String? notes;
  final int exerciseCount;
  final DateTime updatedAt;
}

/// One exercise slot within a [RoutineDraft].
class RoutineExerciseDraft {
  const RoutineExerciseDraft({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.position,
    required this.sets,
    this.notes,
  });

  final String id;
  final String exerciseId;
  final String exerciseName;
  final int position;
  final List<SetTarget> sets;
  final String? notes;
}

/// Full routine data for the edit screen.
class RoutineDraft {
  RoutineDraft({
    required this.id,
    required this.name,
    this.notes,
    required this.exercises,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime(2026);

  final String id;
  final String name;
  final String? notes;
  final List<RoutineExerciseDraft> exercises;
  final DateTime updatedAt;
}

// ---------------------------------------------------------------------------
// RoutinesService
// ---------------------------------------------------------------------------

class RoutinesService {
  RoutinesService(this._db);

  final AppDatabase _db;
  static final _uuid = Uuid();

  // -------------------------------------------------------------------------
  // watchRoutines — ordered by updatedAt desc, includes exerciseCount
  // -------------------------------------------------------------------------

  Stream<List<RoutineSummary>> watchRoutines() {
    // Watch both routines and routineExercises so exercise counts stay live.
    return _db.watchAllRoutines().asyncMap((routineRows) async {
      // Build a count map from routineExercises.
      final allRE = await _db.allRoutineExercises();
      final countMap = <String, int>{};
      for (final re in allRE) {
        countMap[re.routineId] = (countMap[re.routineId] ?? 0) + 1;
      }
      return routineRows.map((r) {
        return RoutineSummary(
          id: r.id,
          name: r.name,
          notes: r.notes,
          exerciseCount: countMap[r.id] ?? 0,
          updatedAt: r.updatedAt,
        );
      }).toList();
    });
  }

  // -------------------------------------------------------------------------
  // getRoutineForEdit — throws NotFoundException if not found
  // -------------------------------------------------------------------------

  Future<RoutineDraft> getRoutineForEdit(String id) async {
    final routine = await _db.routineById(id);
    if (routine == null) throw const NotFoundException();

    final reRows = await _db.routineExercisesForRoutine(id);
    // Collect all unique exercise ids to resolve names in one pass.
    final exerciseIds = reRows.map((re) => re.exerciseId).toSet().toList();
    final nameMap = <String, String>{};
    for (final exId in exerciseIds) {
      final ex = await _db.exerciseById(exId);
      if (ex != null) nameMap[exId] = ex.name;
    }

    final exerciseDrafts = reRows.map((re) {
      return RoutineExerciseDraft(
        id: re.id,
        exerciseId: re.exerciseId,
        exerciseName: nameMap[re.exerciseId] ?? '',
        position: re.position,
        sets: re.sets,
        notes: re.notes,
      );
    }).toList();

    return RoutineDraft(
      id: routine.id,
      name: routine.name,
      notes: routine.notes,
      exercises: exerciseDrafts,
      updatedAt: routine.updatedAt,
    );
  }

  // -------------------------------------------------------------------------
  // createRoutine
  // -------------------------------------------------------------------------

  Future<String> createRoutine({required String name, String? notes}) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    await _db.insertRoutineRow(
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

  // -------------------------------------------------------------------------
  // updateRoutine
  // -------------------------------------------------------------------------

  Future<void> updateRoutine(String id, {String? name, String? notes}) async {
    final existing = await _db.routineById(id);
    if (existing == null) throw const NotFoundException();

    final newUpdatedAt = _advancedTimestamp(existing.updatedAt);
    await _db.updateRoutineRow(
      RoutinesCompanion(
        id: Value(id),
        name: Value(name ?? existing.name),
        notes: notes != null ? Value(notes) : Value(existing.notes),
        createdAt: Value(existing.createdAt),
        updatedAt: Value(newUpdatedAt),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // deleteRoutine — cascade deletes exercises
  // -------------------------------------------------------------------------

  Future<void> deleteRoutine(String id) async {
    await _db.deleteRoutineExercisesForRoutine(id);
    await _db.deleteRoutineById(id);
  }

  // -------------------------------------------------------------------------
  // addExercise — appends at next position, touches routine updatedAt
  // -------------------------------------------------------------------------

  Future<void> addExercise(
    String routineId, {
    required String exerciseId,
    required List<SetTarget> sets,
    String? notes,
  }) async {
    final existing = await _db.routineExercisesForRoutine(routineId);
    final position = existing.isEmpty
        ? 0
        : existing.map((re) => re.position).reduce((a, b) => a > b ? a : b) + 1;

    final id = _uuid.v4();
    await _db.insertRoutineExerciseRow(
      RoutineExercisesCompanion.insert(
        id: id,
        routineId: routineId,
        exerciseId: exerciseId,
        position: position,
        sets: sets,
        notes: Value(notes),
      ),
    );

    // Touch routine updatedAt.
    await _touchRoutine(routineId);
  }

  // -------------------------------------------------------------------------
  // updateExercise
  // -------------------------------------------------------------------------

  Future<void> updateExercise(
    String id, {
    List<SetTarget>? sets,
    String? notes,
  }) async {
    final rows = await ((_db.select(
      _db.routineExercises,
    ))..where((re) => re.id.equals(id))).get();
    if (rows.isEmpty) throw const NotFoundException();
    final existing = rows.first;

    await _db.updateRoutineExerciseRow(
      RoutineExercisesCompanion(
        id: Value(id),
        routineId: Value(existing.routineId),
        exerciseId: Value(existing.exerciseId),
        position: Value(existing.position),
        sets: Value(sets ?? existing.sets),
        notes: notes != null ? Value(notes) : Value(existing.notes),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // removeExercise — deletes and renumbers remaining positions
  // -------------------------------------------------------------------------

  Future<void> removeExercise(String id) async {
    final rows = await ((_db.select(
      _db.routineExercises,
    ))..where((re) => re.id.equals(id))).get();
    if (rows.isEmpty) return;
    final routineId = rows.first.routineId;

    await _db.deleteRoutineExerciseById(id);

    // Renumber remaining exercises.
    final remaining = await _db.routineExercisesForRoutine(routineId);
    for (var i = 0; i < remaining.length; i++) {
      final re = remaining[i];
      if (re.position != i) {
        await _db.updateRoutineExerciseRow(
          RoutineExercisesCompanion(
            id: Value(re.id),
            routineId: Value(re.routineId),
            exerciseId: Value(re.exerciseId),
            position: Value(i),
            sets: Value(re.sets),
            notes: Value(re.notes),
          ),
        );
      }
    }

    await _touchRoutine(routineId);
  }

  // -------------------------------------------------------------------------
  // reorderExercises — persists new positions
  // -------------------------------------------------------------------------

  Future<void> reorderExercises(
    String routineId,
    List<String> orderedIds,
  ) async {
    final reRows = await _db.routineExercisesForRoutine(routineId);
    final byId = {for (final re in reRows) re.id: re};

    for (var i = 0; i < orderedIds.length; i++) {
      final re = byId[orderedIds[i]];
      if (re == null) continue;
      if (re.position != i) {
        await _db.updateRoutineExerciseRow(
          RoutineExercisesCompanion(
            id: Value(re.id),
            routineId: Value(re.routineId),
            exerciseId: Value(re.exerciseId),
            position: Value(i),
            sets: Value(re.sets),
            notes: Value(re.notes),
          ),
        );
      }
    }

    await _touchRoutine(routineId);
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  Future<void> _touchRoutine(String routineId) async {
    final routine = await _db.routineById(routineId);
    if (routine == null) return;
    await _db.updateRoutineRow(
      RoutinesCompanion(
        id: Value(routineId),
        name: Value(routine.name),
        notes: Value(routine.notes),
        createdAt: Value(routine.createdAt),
        updatedAt: Value(_advancedTimestamp(routine.updatedAt)),
      ),
    );
  }

  /// Returns a timestamp strictly after [existing], guaranteed even though
  /// Drift stores `DateTime` at second precision: comparing `DateTime.now()`
  /// directly against `existing` is unreliable, because `now`'s sub-second
  /// component makes it look "later" even when both round-trip to the same
  /// stored second. Bumping [existing] by 1s first and comparing against
  /// *that* closes the gap.
  DateTime _advancedTimestamp(DateTime existing) {
    final bumped = existing.add(const Duration(seconds: 1));
    final now = DateTime.now();
    return now.isAfter(bumped) ? now : bumped;
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final routinesServiceProvider = Provider<RoutinesService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return RoutinesService(db);
});
