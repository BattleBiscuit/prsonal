import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../models/body_metric.dart';
import '../models/exercise.dart';
import '../models/plan.dart';
import '../models/routine_exercise.dart';
import '../models/workout_session.dart';

// One DAO (extension on AppDatabase) per aggregate, each in its own file —
// exported here so importers of app_database.dart keep the same db.method()
// call surface without needing to import every DAO file individually.
export 'daos/body_metrics_dao.dart';
export 'daos/exercises_dao.dart';
export 'daos/plans_dao.dart';
export 'daos/routines_dao.dart';
export 'daos/sessions_dao.dart';

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
  // `.references()`'s onDelete/onUpdate codegen doesn't compile a REFERENCES
  // clause into the schema on this drift_dev version (confirmed empty in the
  // generated table — cascades/restricts were silently never enforced).
  // customConstraint spells out the same clause directly.
  TextColumn get routineId => text().customConstraint(
    'NOT NULL REFERENCES routines(id) ON DELETE CASCADE',
  )();
  TextColumn get exerciseId => text().customConstraint(
    'NOT NULL REFERENCES exercises(id) ON DELETE RESTRICT',
  )();
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
  TextColumn get planId => text().customConstraint(
    'NOT NULL REFERENCES plans(id) ON DELETE CASCADE',
  )();
  TextColumn get routineId => text().customConstraint(
    'NOT NULL REFERENCES routines(id) ON DELETE RESTRICT',
  )();
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
  TextColumn get sessionId => text().customConstraint(
    'NOT NULL REFERENCES workout_sessions(id) ON DELETE CASCADE',
  )();
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

  // SQLite has foreign keys OFF by default per-connection. Without this, the
  // cascade/restrict `onDelete` actions declared on every table above are
  // silently never enforced — deleting a session or routine leaves its sets
  // / exercises as permanently orphaned rows instead of being removed or
  // rejected.
  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'prsonal');
  }
}
