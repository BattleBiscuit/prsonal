import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';

import '../models/body_metric.dart';
import '../models/exercise.dart';
import '../models/plan.dart';
import '../models/routine_exercise.dart';
import '../models/workout_session.dart';

part 'app_database.g.dart';

// ---------------------------------------------------------------------------
// TypeConverters
// ---------------------------------------------------------------------------

/// Converts [ExerciseType] to/from its stored string name.
class ExerciseTypeConverter extends TypeConverter<ExerciseType, String> {
  const ExerciseTypeConverter();

  @override
  ExerciseType fromSql(String fromDb) => ExerciseType.values.byName(fromDb);

  @override
  String toSql(ExerciseType value) => value.name;
}

/// Converts [SessionStatus] to/from its stored string name.
class SessionStatusConverter extends TypeConverter<SessionStatus, String> {
  const SessionStatusConverter();

  @override
  SessionStatus fromSql(String fromDb) => SessionStatus.values.byName(fromDb);

  @override
  String toSql(SessionStatus value) => value.name;
}

/// Converts [PlanStatus] to/from its stored string name.
class PlanStatusConverter extends TypeConverter<PlanStatus, String> {
  const PlanStatusConverter();

  @override
  PlanStatus fromSql(String fromDb) => PlanStatus.values.byName(fromDb);

  @override
  String toSql(PlanStatus value) => value.name;
}

/// Converts [BodyMetricType] to/from its stored string name.
class BodyMetricTypeConverter extends TypeConverter<BodyMetricType, String> {
  const BodyMetricTypeConverter();

  @override
  BodyMetricType fromSql(String fromDb) => BodyMetricType.values.byName(fromDb);

  @override
  String toSql(BodyMetricType value) => value.name;
}

/// Converts [List<Muscle>] to/from a JSON string array.
class MuscleListConverter extends TypeConverter<List<Muscle>, String> {
  const MuscleListConverter();

  @override
  List<Muscle> fromSql(String fromDb) {
    final list = jsonDecode(fromDb) as List<dynamic>;
    return list.map((e) => Muscle.values.byName(e as String)).toList();
  }

  @override
  String toSql(List<Muscle> value) =>
      jsonEncode(value.map((m) => m.name).toList());
}

/// Converts [List<SetTarget>] to/from a JSON string array.
class SetTargetListConverter extends TypeConverter<List<SetTarget>, String> {
  const SetTargetListConverter();

  @override
  List<SetTarget> fromSql(String fromDb) {
    final list = jsonDecode(fromDb) as List<dynamic>;
    return list
        .map((e) => SetTarget.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  String toSql(List<SetTarget> value) =>
      jsonEncode(value.map((s) => s.toJson()).toList());
}

// ---------------------------------------------------------------------------
// Table definitions
// ---------------------------------------------------------------------------

class Exercises extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get type => text().map(const ExerciseTypeConverter())();
  TextColumn get primaryMuscles => text()
      .map(const MuscleListConverter())
      .withDefault(const Constant('[]'))();
  TextColumn get secondaryMuscles => text()
      .map(const MuscleListConverter())
      .withDefault(const Constant('[]'))();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Routines extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class RoutineExercises extends Table {
  TextColumn get id => text()();
  TextColumn get routineId =>
      text().references(Routines, #id, onDelete: KeyAction.cascade)();
  TextColumn get exerciseId =>
      text().references(Exercises, #id, onDelete: KeyAction.restrict)();
  IntColumn get position => integer()();
  TextColumn get notes => text().nullable()();
  // JSON list of SetTarget objects
  TextColumn get sets => text().map(const SetTargetListConverter())();

  @override
  Set<Column> get primaryKey => {id};
}

class Plans extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get status => text().map(const PlanStatusConverter())();
  IntColumn get order => integer()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class PlanEntries extends Table {
  TextColumn get id => text()();
  TextColumn get planId =>
      text().references(Plans, #id, onDelete: KeyAction.cascade)();
  TextColumn get routineId =>
      text().references(Routines, #id, onDelete: KeyAction.restrict)();
  IntColumn get dayOfWeek => integer().nullable()();
  IntColumn get order => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

class WorkoutSessions extends Table {
  TextColumn get id => text()();
  TextColumn get routineId => text()();
  TextColumn get routineName => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  TextColumn get status => text().map(const SessionStatusConverter())();
  TextColumn get planId => text().nullable()();
  TextColumn get planEntryId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class WorkoutSets extends Table {
  TextColumn get id => text()();
  TextColumn get sessionId =>
      text().references(WorkoutSessions, #id, onDelete: KeyAction.cascade)();
  IntColumn get exercisePosition => integer()();
  TextColumn get exerciseId => text().nullable()();
  TextColumn get exerciseName => text()();
  IntColumn get setIndex => integer()();
  TextColumn get type => text().map(const ExerciseTypeConverter())();
  IntColumn get plannedReps => integer().nullable()();
  RealColumn get plannedWeight => real().nullable()();
  BoolColumn get isBodyweight => boolean().withDefault(const Constant(false))();
  IntColumn get actualReps => integer().nullable()();
  RealColumn get actualWeight => real().nullable()();
  RealColumn get effectiveWeight => real().nullable()();
  IntColumn get plannedDuration => integer().nullable()();
  IntColumn get plannedLevel => integer().nullable()();
  IntColumn get actualDuration => integer().nullable()();
  IntColumn get actualLevel => integer().nullable()();
  IntColumn get restSeconds => integer().withDefault(const Constant(0))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  BoolColumn get skipped => boolean().withDefault(const Constant(false))();
  BoolColumn get isPR => boolean().withDefault(const Constant(false))();
  RealColumn get estimated1RM => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class BodyMetrics extends Table {
  TextColumn get id => text()();
  TextColumn get type => text().map(const BodyMetricTypeConverter())();
  RealColumn get value => real()();
  DateTimeColumn get loggedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------------------
// SeedSet — test-support helper value object
// ---------------------------------------------------------------------------

/// Describes one row to insert via [AppDatabase.seedCompletedSession].
/// Imported by service tests from this file.
class SeedSet {
  const SeedSet({
    required this.exercisePosition,
    required this.exerciseName,
    this.exerciseId,
    required this.setIndex,
    required this.type,
    this.actualReps,
    this.actualWeight,
    this.effectiveWeight,
    this.estimated1RM,
    this.completedAt,
    required this.skipped,
    required this.isPR,
  });

  final int exercisePosition;
  final String exerciseName;
  final String? exerciseId;
  final int setIndex;
  final ExerciseType type;
  final int? actualReps;
  final double? actualWeight;
  final double? effectiveWeight;
  final double? estimated1RM;
  final DateTime? completedAt;
  final bool skipped;
  final bool isPR;
}

// ---------------------------------------------------------------------------
// AppDatabase
// ---------------------------------------------------------------------------

@DriftDatabase(
  tables: [
    Exercises,
    Routines,
    RoutineExercises,
    Plans,
    PlanEntries,
    WorkoutSessions,
    WorkoutSets,
    BodyMetrics,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Production constructor — opens the on-device SQLite file.
  AppDatabase() : super(_openConnection());

  /// Test constructor — accepts any [QueryExecutor] (typically NativeDatabase.memory()).
  AppDatabase.forTesting(super.e);

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'prsonal');
  }

  // -------------------------------------------------------------------------
  // UUID helper
  // -------------------------------------------------------------------------
  static final _uuid = Uuid();
  static String _newId() => _uuid.v4();

  // =========================================================================
  // Test-support helpers
  // =========================================================================

  /// Inserts an exercise with a generated UUID and returns the id.
  Future<String> insertExercise({
    required String name,
    required ExerciseType type,
    List<Muscle> primaryMuscles = const [],
    List<Muscle> secondaryMuscles = const [],
    String? notes,
  }) async {
    final id = _newId();
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

  /// Inserts a routine with a generated UUID and returns the id.
  Future<String> insertRoutine({required String name, String? notes}) async {
    final id = _newId();
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
    final sessionId = _newId();
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
          id: _newId(),
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

  // =========================================================================
  // Query helpers used by service tests
  // =========================================================================

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

  // =========================================================================
  // Exercise queries
  // =========================================================================

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

  // =========================================================================
  // Routine queries
  // =========================================================================

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

  // =========================================================================
  // RoutineExercise queries
  // =========================================================================

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

  // =========================================================================
  // Plan queries
  // =========================================================================

  /// Returns all plans ordered by their order field.
  Future<List<Plan>> allPlans() {
    return (select(plans)..orderBy([(p) => OrderingTerm.asc(p.order)])).get();
  }

  /// Returns a stream of all plans.
  Stream<List<Plan>> watchAllPlans() {
    return (select(plans)..orderBy([(p) => OrderingTerm.asc(p.order)])).watch();
  }

  /// Returns a single plan by id, or null.
  Future<Plan?> planById(String id) {
    return (select(plans)..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  /// Inserts a plan row.
  Future<void> insertPlanRow(PlansCompanion row) => into(plans).insert(row);

  /// Updates a plan row.
  Future<bool> updatePlanRow(PlansCompanion row) => update(plans).replace(row);

  /// Deletes a plan by id.
  Future<int> deletePlanById(String id) =>
      (delete(plans)..where((p) => p.id.equals(id))).go();

  // =========================================================================
  // PlanEntry queries
  // =========================================================================

  /// Returns a stream that emits whenever any plan entry changes.
  Stream<List<PlanEntry>> watchAllPlanEntries() {
    return select(planEntries).watch();
  }

  /// Returns all entries for a plan in order.
  Future<List<PlanEntry>> planEntriesForPlan(String planId) {
    return (select(planEntries)
          ..where((pe) => pe.planId.equals(planId))
          ..orderBy([(pe) => OrderingTerm.asc(pe.order)]))
        .get();
  }

  /// Inserts a plan entry row.
  Future<void> insertPlanEntryRow(PlanEntriesCompanion row) =>
      into(planEntries).insert(row);

  /// Deletes all entries for a plan.
  Future<int> deletePlanEntriesForPlan(String planId) =>
      (delete(planEntries)..where((pe) => pe.planId.equals(planId))).go();

  // =========================================================================
  // WorkoutSession queries
  // =========================================================================

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

  // =========================================================================
  // WorkoutSet queries
  // =========================================================================

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

  // =========================================================================
  // BodyMetric queries
  // =========================================================================

  /// Returns a stream of body metrics for [type] ordered by loggedAt descending.
  Stream<List<BodyMetric>> watchBodyMetrics(BodyMetricType type) {
    return (select(bodyMetrics)
          ..where((b) => b.type.equals(type.name))
          ..orderBy([(b) => OrderingTerm.desc(b.loggedAt)]))
        .watch();
  }

  /// Returns the most recent body metric for [type], or null.
  Future<BodyMetric?> latestBodyMetric(BodyMetricType type) {
    return (select(bodyMetrics)
          ..where((b) => b.type.equals(type.name))
          ..orderBy([(b) => OrderingTerm.desc(b.loggedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Returns the most recent body metric for each type.
  Future<Map<BodyMetricType, BodyMetric>> latestBodyMetrics() async {
    final result = <BodyMetricType, BodyMetric>{};
    for (final type in BodyMetricType.values) {
      final row = await latestBodyMetric(type);
      if (row != null) result[type] = row;
    }
    return result;
  }

  /// Inserts a body metric row.
  Future<void> insertBodyMetricRow(BodyMetricsCompanion row) =>
      into(bodyMetrics).insert(row);

  /// Deletes a body metric by id.
  Future<int> deleteBodyMetricById(String id) =>
      (delete(bodyMetrics)..where((b) => b.id.equals(id))).go();

  // =========================================================================
  // Bulk export / import (used by BackupService)
  // =========================================================================

  /// Returns all rows from a table as a list. Used by BackupService.
  Future<List<Exercise>> allExercises() => select(exercises).get();
  Future<List<Routine>> allRoutines() => select(routines).get();
  Future<List<RoutineExercise>> allRoutineExercises() =>
      select(routineExercises).get();
  Future<List<Plan>> allPlans2() => select(plans).get();
  Future<List<PlanEntry>> allPlanEntries() => select(planEntries).get();
  Future<List<WorkoutSession>> allWorkoutSessions() =>
      select(workoutSessions).get();
  Future<List<WorkoutSet>> allWorkoutSets() => select(workoutSets).get();
  Future<List<BodyMetric>> allBodyMetrics() => select(bodyMetrics).get();

  /// Clears all rows from a table. Used by BackupService before re-import.
  Future<void> clearExercises() => delete(exercises).go();
  Future<void> clearRoutines() => delete(routines).go();
  Future<void> clearRoutineExercises() => delete(routineExercises).go();
  Future<void> clearPlans() => delete(plans).go();
  Future<void> clearPlanEntries() => delete(planEntries).go();
  Future<void> clearWorkoutSessions() => delete(workoutSessions).go();
  Future<void> clearWorkoutSets() => delete(workoutSets).go();
  Future<void> deleteWorkoutSetsForSession(String sessionId) =>
      (delete(workoutSets)..where((t) => t.sessionId.equals(sessionId))).go();
  Future<void> clearBodyMetrics() => delete(bodyMetrics).go();

  /// Bulk-inserts exercise rows (for restore).
  Future<void> bulkInsertExercises(List<ExercisesCompanion> rows) async {
    await batch((b) => b.insertAll(exercises, rows));
  }

  Future<void> bulkInsertRoutines(List<RoutinesCompanion> rows) async {
    await batch((b) => b.insertAll(routines, rows));
  }

  Future<void> bulkInsertRoutineExercises(
    List<RoutineExercisesCompanion> rows,
  ) async {
    await batch((b) => b.insertAll(routineExercises, rows));
  }

  Future<void> bulkInsertPlans(List<PlansCompanion> rows) async {
    await batch((b) => b.insertAll(plans, rows));
  }

  Future<void> bulkInsertPlanEntries(List<PlanEntriesCompanion> rows) async {
    await batch((b) => b.insertAll(planEntries, rows));
  }

  Future<void> bulkInsertWorkoutSessions(
    List<WorkoutSessionsCompanion> rows,
  ) async {
    await batch((b) => b.insertAll(workoutSessions, rows));
  }

  Future<void> bulkInsertWorkoutSets(List<WorkoutSetsCompanion> rows) async {
    await batch((b) => b.insertAll(workoutSets, rows));
  }

  Future<void> bulkInsertBodyMetrics(List<BodyMetricsCompanion> rows) async {
    await batch((b) => b.insertAll(bodyMetrics, rows));
  }
}
