import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../models/exercise.dart';
import '../providers/app_providers.dart';

// ---------------------------------------------------------------------------
// View-model types
// ---------------------------------------------------------------------------

/// One exercise row with its computed best estimated 1RM.
class LibraryExercise {
  const LibraryExercise({
    required this.id,
    required this.name,
    required this.type,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    this.notes,
    this.bestOneRepMax,
  });

  final String id;
  final String name;
  final ExerciseType type;
  final List<Muscle> primaryMuscles;
  final List<Muscle> secondaryMuscles;
  final String? notes;
  final double? bestOneRepMax;
}

// ---------------------------------------------------------------------------
// LibraryService
// ---------------------------------------------------------------------------

class LibraryService {
  LibraryService(this._db);

  final AppDatabase _db;
  static final _uuid = Uuid();

  // -------------------------------------------------------------------------
  // watchExercises — alphabetical, with bestOneRepMax
  // -------------------------------------------------------------------------

  Stream<List<LibraryExercise>> watchExercises() {
    return _db.watchAllExercises().asyncMap((rows) async {
      final prMap = await _db.bestOneRepMaxByExerciseId();
      return rows.map((e) {
        return LibraryExercise(
          id: e.id,
          name: e.name,
          type: e.type,
          primaryMuscles: e.primaryMuscles,
          secondaryMuscles: e.secondaryMuscles,
          notes: e.notes,
          bestOneRepMax: prMap[e.id],
        );
      }).toList();
    });
  }

  // -------------------------------------------------------------------------
  // searchExercises — case-insensitive name substring
  // -------------------------------------------------------------------------

  Future<List<LibraryExercise>> searchExercises(String query) async {
    final rows = await _db.searchExercises(query);
    final prMap = await _db.bestOneRepMaxByExerciseId();
    return rows.map((e) {
      return LibraryExercise(
        id: e.id,
        name: e.name,
        type: e.type,
        primaryMuscles: e.primaryMuscles,
        secondaryMuscles: e.secondaryMuscles,
        notes: e.notes,
        bestOneRepMax: prMap[e.id],
      );
    }).toList();
  }

  // -------------------------------------------------------------------------
  // createExercise — inserts, returns id
  // -------------------------------------------------------------------------

  Future<String> createExercise({
    required String name,
    required ExerciseType type,
    required List<Muscle> primaryMuscles,
    required List<Muscle> secondaryMuscles,
    String? notes,
  }) async {
    final id = _uuid.v4();
    await _db.insertExerciseRow(
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

  // -------------------------------------------------------------------------
  // updateExercise — updates provided fields
  // -------------------------------------------------------------------------

  Future<void> updateExercise(
    String id, {
    String? name,
    ExerciseType? type,
    List<Muscle>? primaryMuscles,
    List<Muscle>? secondaryMuscles,
    String? notes,
  }) async {
    final existing = await _db.exerciseById(id);
    if (existing == null) return;

    await _db.updateExerciseRow(
      ExercisesCompanion(
        id: Value(id),
        name: Value(name ?? existing.name),
        type: Value(type ?? existing.type),
        primaryMuscles: Value(primaryMuscles ?? existing.primaryMuscles),
        secondaryMuscles: Value(secondaryMuscles ?? existing.secondaryMuscles),
        notes: notes != null ? Value(notes) : Value(existing.notes),
        createdAt: Value(existing.createdAt),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // deleteExercise
  // -------------------------------------------------------------------------

  Future<void> deleteExercise(String id) async {
    await _db.deleteExerciseById(id);
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final libraryServiceProvider = Provider<LibraryService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return LibraryService(db);
});
