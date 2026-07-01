import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../models/exercise.dart';
import '../../models/workout_session.dart';
import '../app_database.dart';

/// Workout-session + workout-set queries. Kept as extension methods on
/// [AppDatabase] (rather than a `@DriftAccessor` DAO class) so call sites
/// keep the same `db.method()` surface used throughout the app's services.
extension SessionsDao on AppDatabase {
  static final _uuid = Uuid();

  /// Seeds a completed workout session with optional sets. Returns the session id.
  ///
  /// If [routineName] is omitted it defaults to an empty string (tests that
  /// don't care about the name may omit it).
  Future<String> seedCompletedSession({
    required String routineId,
    String? routineName,
    String? planId,
    String? planEntryId,
    required DateTime startedAt,
    DateTime? completedAt,
    List<SeedSet> sets = const [],
  }) async {
    final sessionId = _uuid.v4();
    final resolvedCompletedAt =
        completedAt ?? startedAt.add(const Duration(minutes: 30));
    await into(workoutSessions).insert(
      WorkoutSessionsCompanion.insert(
        id: sessionId,
        routineId: routineId,
        routineName: routineName ?? '',
        startedAt: startedAt,
        completedAt: Value(resolvedCompletedAt),
        status: SessionStatus.completed,
        planId: Value(planId),
        planEntryId: Value(planEntryId),
      ),
    );
    for (final s in sets) {
      await into(workoutSets).insert(
        WorkoutSetsCompanion.insert(
          id: _uuid.v4(),
          sessionId: sessionId,
          exercisePosition: s.exercisePosition,
          exerciseId: Value(s.exerciseId),
          exerciseName: s.exerciseName,
          setIndex: s.setIndex,
          type: s.type,
          actualReps: Value(s.actualReps),
          actualWeight: Value(s.actualWeight),
          effectiveWeight: Value(s.effectiveWeight),
          estimated1RM: Value(s.estimated1RM),
          completedAt: Value(s.completedAt),
          skipped: Value(s.skipped),
          isPR: Value(s.isPR),
        ),
      );
    }
    return sessionId;
  }

  /// Returns all workout sets for [sessionId], ordered by position then index.
  Future<List<WorkoutSet>> workoutSetsForSession(String sessionId) {
    return (select(workoutSets)
          ..where((s) => s.sessionId.equals(sessionId))
          ..orderBy([
            (s) => OrderingTerm.asc(s.exercisePosition),
            (s) => OrderingTerm.asc(s.setIndex),
          ]))
        .get();
  }

  /// Returns the session row for [id], or null when not found.
  Future<WorkoutSession?> sessionById(String id) {
    return (select(
      workoutSessions,
    )..where((s) => s.id.equals(id))).getSingleOrNull();
  }

  /// Returns all completed sessions ordered by startedAt descending.
  Future<List<WorkoutSession>> completedSessions({int? limit, int? offset}) {
    return (select(workoutSessions)
          ..where((s) => s.status.equals(SessionStatus.completed.name))
          ..orderBy([(s) => OrderingTerm.desc(s.startedAt)])
          ..limit(limit ?? -1, offset: offset))
        .get();
  }

  /// Returns a stream of completed sessions, newest first.
  Stream<List<WorkoutSession>> watchCompletedSessions() {
    return (select(workoutSessions)
          ..where((s) => s.status.equals(SessionStatus.completed.name))
          ..orderBy([(s) => OrderingTerm.desc(s.startedAt)]))
        .watch();
  }

  /// Returns a count of all completed sessions.
  Future<int> completedSessionCount() async {
    final countExpr = workoutSessions.id.count();
    final query = selectOnly(workoutSessions)
      ..addColumns([countExpr])
      ..where(workoutSessions.status.equals(SessionStatus.completed.name));
    final row = await query.getSingle();
    return row.read(countExpr) ?? 0;
  }

  /// Returns completed sessions whose startedAt falls within [from]..[to].
  Future<List<WorkoutSession>> completedSessionsInRange(
    DateTime from,
    DateTime to,
  ) {
    return (select(workoutSessions)
          ..where(
            (s) =>
                s.status.equals(SessionStatus.completed.name) &
                s.startedAt.isBetweenValues(from, to),
          )
          ..orderBy([(s) => OrderingTerm.desc(s.startedAt)]))
        .get();
  }

  /// Returns the currently active session (status = active), or null.
  Future<WorkoutSession?> activeSession() {
    return (select(workoutSessions)
          ..where((s) => s.status.equals(SessionStatus.active.name)))
        .getSingleOrNull();
  }

  /// Inserts a workout session row.
  Future<void> insertWorkoutSessionRow(WorkoutSessionsCompanion row) =>
      into(workoutSessions).insert(row);

  /// Updates a workout session row.
  Future<bool> updateWorkoutSessionRow(WorkoutSessionsCompanion row) =>
      update(workoutSessions).replace(row);

  /// Deletes a workout session and all of its sets (cascade handles sets).
  Future<int> deleteWorkoutSessionById(String id) =>
      (delete(workoutSessions)..where((s) => s.id.equals(id))).go();

  // ---------------------------------------------------------------------------
  // WorkoutSet queries
  // ---------------------------------------------------------------------------

  /// Inserts a workout set row.
  Future<void> insertWorkoutSetRow(WorkoutSetsCompanion row) =>
      into(workoutSets).insert(row);

  /// Updates a workout set row.
  Future<bool> updateWorkoutSetRow(WorkoutSetsCompanion row) =>
      update(workoutSets).replace(row);

  /// Returns the best estimated1RM per exercise (by exerciseId) from PR sets.
  Future<Map<String, double>> bestOneRepMaxByExerciseId() async {
    final q = selectOnly(workoutSets)
      ..addColumns([workoutSets.exerciseId, workoutSets.estimated1RM.max()])
      ..where(
        workoutSets.isPR.equals(true) & workoutSets.exerciseId.isNotNull(),
      )
      ..groupBy([workoutSets.exerciseId]);
    final rows = await q.get();
    final result = <String, double>{};
    for (final row in rows) {
      final id = row.read(workoutSets.exerciseId);
      final best = row.read(workoutSets.estimated1RM.max());
      if (id != null && best != null) result[id] = best;
    }
    return result;
  }

  /// Returns all PR sets for [exerciseId] ordered by estimated1RM desc.
  Future<List<WorkoutSet>> prSetsForExercise(String exerciseId) {
    return (select(workoutSets)
          ..where((s) => s.exerciseId.equals(exerciseId) & s.isPR.equals(true))
          ..orderBy([(s) => OrderingTerm.desc(s.estimated1RM)]))
        .get();
  }

  /// Returns the highest [estimated1RM] recorded for a given exercise across
  /// all completed (non-skipped, non-null completedAt) strength sets.
  ///
  /// Matches by [exerciseId] when provided, falling back to [exerciseName].
  /// Returns 0.0 when no prior data exists (making any non-zero 1RM a PR).
  Future<double> bestEstimated1RMForExercise({
    String? exerciseId,
    String? exerciseName,
    String? excludeSessionId,
    String? beforeSetId,
    String? currentSessionId,
  }) async {
    final maxExpr = workoutSets.estimated1RM.max();
    final q = selectOnly(workoutSets)..addColumns([maxExpr]);

    // Must be a completed strength set.
    var where =
        workoutSets.type.equals(ExerciseType.strength.name) &
        workoutSets.skipped.equals(false) &
        workoutSets.completedAt.isNotNull() &
        workoutSets.estimated1RM.isNotNull();

    // Match by exerciseId or exerciseName.
    if (exerciseId != null) {
      where = where & workoutSets.exerciseId.equals(exerciseId);
    } else if (exerciseName != null) {
      where = where & workoutSets.exerciseName.equals(exerciseName);
    }

    q.where(where);
    final row = await q.getSingle();
    return row.read(maxExpr) ?? 0.0;
  }

  /// Returns all PR sets (isPR = true) for sessions started within [from]..[to].
  Future<List<WorkoutSet>> prSetsInSessionRange(List<String> sessionIds) async {
    if (sessionIds.isEmpty) return [];
    return (select(workoutSets)
          ..where((s) => s.isPR.equals(true) & s.sessionId.isIn(sessionIds))
          ..orderBy([(s) => OrderingTerm.desc(s.estimated1RM)]))
        .get();
  }

  // ---------------------------------------------------------------------------
  // Bulk export / import (used by BackupService)
  // ---------------------------------------------------------------------------

  Future<List<WorkoutSession>> allWorkoutSessions() =>
      select(workoutSessions).get();
  Future<List<WorkoutSet>> allWorkoutSets() => select(workoutSets).get();

  Future<void> clearWorkoutSessions() => delete(workoutSessions).go();
  Future<void> clearWorkoutSets() => delete(workoutSets).go();
  Future<void> deleteWorkoutSetsForSession(String sessionId) =>
      (delete(workoutSets)..where((t) => t.sessionId.equals(sessionId))).go();

  Future<void> bulkInsertWorkoutSessions(
    List<WorkoutSessionsCompanion> rows,
  ) async {
    await batch((b) => b.insertAll(workoutSessions, rows));
  }

  Future<void> bulkInsertWorkoutSets(List<WorkoutSetsCompanion> rows) async {
    await batch((b) => b.insertAll(workoutSets, rows));
  }
}
