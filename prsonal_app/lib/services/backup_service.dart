import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../models/exercise.dart';
import '../models/plan.dart';
import '../models/routine_exercise.dart';
import '../models/workout_session.dart';
import '../providers/app_providers.dart';

// ---------------------------------------------------------------------------
// BackupSection enum
// ---------------------------------------------------------------------------

/// Selectable sections of a backup document.
enum BackupSection { library, routines, plans, history }

// ---------------------------------------------------------------------------
// Manual serialization helpers
// (Drift's default toJson() does not invoke TypeConverters, so enums/custom
//  types remain as Dart objects and are not JSON-encodable. We serialize
//  each column field explicitly.)
// ---------------------------------------------------------------------------

Map<String, dynamic> _exerciseToMap(Exercise e) => {
  'id': e.id,
  'name': e.name,
  'type': e.type.name,
  'primaryMuscles': e.primaryMuscles.map((m) => m.name).toList(),
  'secondaryMuscles': e.secondaryMuscles.map((m) => m.name).toList(),
  'notes': e.notes,
  'createdAt': e.createdAt.millisecondsSinceEpoch,
};

Exercise _exerciseFromMap(Map<String, dynamic> m) => Exercise(
  id: m['id'] as String,
  name: m['name'] as String,
  type: ExerciseType.values.byName(m['type'] as String),
  primaryMuscles: (m['primaryMuscles'] as List<dynamic>)
      .map((v) => Muscle.values.byName(v as String))
      .toList(),
  secondaryMuscles: (m['secondaryMuscles'] as List<dynamic>)
      .map((v) => Muscle.values.byName(v as String))
      .toList(),
  notes: m['notes'] as String?,
  createdAt: _parseDateTime(m['createdAt']),
);

Map<String, dynamic> _routineToMap(Routine r) => {
  'id': r.id,
  'name': r.name,
  'notes': r.notes,
  'createdAt': r.createdAt.millisecondsSinceEpoch,
  'updatedAt': r.updatedAt.millisecondsSinceEpoch,
};

Routine _routineFromMap(Map<String, dynamic> m) => Routine(
  id: m['id'] as String,
  name: m['name'] as String,
  notes: m['notes'] as String?,
  createdAt: _parseDateTime(m['createdAt']),
  updatedAt: _parseDateTime(m['updatedAt']),
);

Map<String, dynamic> _routineExerciseToMap(RoutineExercise re) => {
  'id': re.id,
  'routineId': re.routineId,
  'exerciseId': re.exerciseId,
  'position': re.position,
  'notes': re.notes,
  'sets': re.sets.map((s) => s.toJson()).toList(),
};

RoutineExercise _routineExerciseFromMap(Map<String, dynamic> m) =>
    RoutineExercise(
      id: m['id'] as String,
      routineId: m['routineId'] as String,
      exerciseId: m['exerciseId'] as String,
      position: m['position'] as int,
      notes: m['notes'] as String?,
      sets: (m['sets'] as List<dynamic>)
          .map((e) => SetTarget.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _planToMap(Plan p) => {
  'id': p.id,
  'name': p.name,
  'status': p.status.name,
  'order': p.order,
  'createdAt': p.createdAt.millisecondsSinceEpoch,
};

Plan _planFromMap(Map<String, dynamic> m) => Plan(
  id: m['id'] as String,
  name: m['name'] as String,
  status: PlanStatus.values.byName(m['status'] as String),
  order: m['order'] as int,
  createdAt: _parseDateTime(m['createdAt']),
);

Map<String, dynamic> _planEntryToMap(PlanEntry e) => {
  'id': e.id,
  'planId': e.planId,
  'routineId': e.routineId,
  'dayOfWeek': e.dayOfWeek,
  'order': e.order,
};

PlanEntry _planEntryFromMap(Map<String, dynamic> m) => PlanEntry(
  id: m['id'] as String,
  planId: m['planId'] as String,
  routineId: m['routineId'] as String,
  dayOfWeek: m['dayOfWeek'] as int?,
  order: m['order'] as int,
);

Map<String, dynamic> _sessionToMap(WorkoutSession s) => {
  'id': s.id,
  'routineId': s.routineId,
  'routineName': s.routineName,
  'startedAt': s.startedAt.millisecondsSinceEpoch,
  'completedAt': s.completedAt?.millisecondsSinceEpoch,
  'status': s.status.name,
  'planId': s.planId,
  'planEntryId': s.planEntryId,
};

WorkoutSession _sessionFromMap(Map<String, dynamic> m) => WorkoutSession(
  id: m['id'] as String,
  routineId: m['routineId'] as String,
  routineName: m['routineName'] as String,
  startedAt: _parseDateTime(m['startedAt']),
  completedAt: m['completedAt'] != null
      ? _parseDateTime(m['completedAt'])
      : null,
  status: SessionStatus.values.byName(m['status'] as String),
  planId: m['planId'] as String?,
  planEntryId: m['planEntryId'] as String?,
);

Map<String, dynamic> _workoutSetToMap(WorkoutSet s) => {
  'id': s.id,
  'sessionId': s.sessionId,
  'exercisePosition': s.exercisePosition,
  'exerciseId': s.exerciseId,
  'exerciseName': s.exerciseName,
  'setIndex': s.setIndex,
  'type': s.type.name,
  'plannedReps': s.plannedReps,
  'plannedWeight': s.plannedWeight,
  'isBodyweight': s.isBodyweight,
  'actualReps': s.actualReps,
  'actualWeight': s.actualWeight,
  'effectiveWeight': s.effectiveWeight,
  'plannedDuration': s.plannedDuration,
  'plannedLevel': s.plannedLevel,
  'actualDuration': s.actualDuration,
  'actualLevel': s.actualLevel,
  'restSeconds': s.restSeconds,
  'completedAt': s.completedAt?.millisecondsSinceEpoch,
  'skipped': s.skipped,
  'isPR': s.isPR,
  'estimated1RM': s.estimated1RM,
};

WorkoutSet _workoutSetFromMap(Map<String, dynamic> m) => WorkoutSet(
  id: m['id'] as String,
  sessionId: m['sessionId'] as String,
  exercisePosition: m['exercisePosition'] as int,
  exerciseId: m['exerciseId'] as String?,
  exerciseName: m['exerciseName'] as String,
  setIndex: m['setIndex'] as int,
  type: ExerciseType.values.byName(m['type'] as String),
  plannedReps: m['plannedReps'] as int?,
  plannedWeight: (m['plannedWeight'] as num?)?.toDouble(),
  isBodyweight: m['isBodyweight'] as bool? ?? false,
  actualReps: m['actualReps'] as int?,
  actualWeight: (m['actualWeight'] as num?)?.toDouble(),
  effectiveWeight: (m['effectiveWeight'] as num?)?.toDouble(),
  plannedDuration: m['plannedDuration'] as int?,
  plannedLevel: m['plannedLevel'] as int?,
  actualDuration: m['actualDuration'] as int?,
  actualLevel: m['actualLevel'] as int?,
  restSeconds: m['restSeconds'] as int? ?? 0,
  completedAt: m['completedAt'] != null
      ? _parseDateTime(m['completedAt'])
      : null,
  skipped: m['skipped'] as bool? ?? false,
  isPR: m['isPR'] as bool? ?? false,
  estimated1RM: (m['estimated1RM'] as num?)?.toDouble(),
);

DateTime _parseDateTime(dynamic value) {
  if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
  return DateTime.parse(value.toString());
}

// ---------------------------------------------------------------------------
// BackupService
// ---------------------------------------------------------------------------

class BackupService {
  BackupService(this._db);

  final AppDatabase _db;

  // -------------------------------------------------------------------------
  // counts — number of records per section
  // -------------------------------------------------------------------------

  Future<Map<BackupSection, int>> counts() async {
    final exercises = await _db.allExercises();
    final routines = await _db.allRoutines();
    final plans = await _db.allPlans2();
    final sessions = await _db.allWorkoutSessions();

    return {
      BackupSection.library: exercises.length,
      BackupSection.routines: routines.length,
      BackupSection.plans: plans.length,
      BackupSection.history: sessions.length,
    };
  }

  // -------------------------------------------------------------------------
  // exportJson — serialise selected sections
  // -------------------------------------------------------------------------

  Future<String> exportJson({required Set<BackupSection> sections}) async {
    final doc = <String, dynamic>{'_version': 1};

    if (sections.contains(BackupSection.library)) {
      final rows = await _db.allExercises();
      doc['library'] = rows.map(_exerciseToMap).toList();
    }

    if (sections.contains(BackupSection.routines)) {
      final routineRows = await _db.allRoutines();
      final reRows = await _db.allRoutineExercises();
      doc['routines'] = routineRows.map(_routineToMap).toList();
      doc['routineExercises'] = reRows.map(_routineExerciseToMap).toList();
    }

    if (sections.contains(BackupSection.plans)) {
      final planRows = await _db.allPlans2();
      final entryRows = await _db.allPlanEntries();
      doc['plans'] = planRows.map(_planToMap).toList();
      doc['planEntries'] = entryRows.map(_planEntryToMap).toList();
    }

    if (sections.contains(BackupSection.history)) {
      final sessionRows = await _db.allWorkoutSessions();
      final setRows = await _db.allWorkoutSets();
      doc['sessions'] = sessionRows.map(_sessionToMap).toList();
      doc['workoutSets'] = setRows.map(_workoutSetToMap).toList();
    }

    return jsonEncode(doc);
  }

  // -------------------------------------------------------------------------
  // importJson — replace selected sections with document contents
  // -------------------------------------------------------------------------

  Future<void> importJson(
    String json, {
    required Set<BackupSection> sections,
  }) async {
    final Map<String, dynamic> doc;
    try {
      final decoded = jsonDecode(json);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Backup document must be a JSON object.');
      }
      doc = decoded;
    } on FormatException {
      rethrow;
    } catch (e) {
      throw FormatException('Invalid backup JSON: $e');
    }

    if (sections.contains(BackupSection.library)) {
      await _db.clearExercises();
      final rawList = doc['library'];
      if (rawList is List) {
        final companions = rawList
            .cast<Map<String, dynamic>>()
            .map((m) => _exerciseFromMap(m).toCompanion(false))
            .toList();
        await _db.bulkInsertExercises(companions);
      }
    }

    if (sections.contains(BackupSection.routines)) {
      await _db.clearRoutineExercises();
      await _db.clearRoutines();

      final rawRoutines = doc['routines'];
      if (rawRoutines is List) {
        final companions = rawRoutines
            .cast<Map<String, dynamic>>()
            .map((m) => _routineFromMap(m).toCompanion(false))
            .toList();
        await _db.bulkInsertRoutines(companions);
      }

      final rawREs = doc['routineExercises'];
      if (rawREs is List) {
        final companions = rawREs
            .cast<Map<String, dynamic>>()
            .map((m) => _routineExerciseFromMap(m).toCompanion(false))
            .toList();
        await _db.bulkInsertRoutineExercises(companions);
      }
    }

    if (sections.contains(BackupSection.plans)) {
      await _db.clearPlanEntries();
      await _db.clearPlans();

      final rawPlans = doc['plans'];
      if (rawPlans is List) {
        final companions = rawPlans
            .cast<Map<String, dynamic>>()
            .map((m) => _planFromMap(m).toCompanion(false))
            .toList();
        await _db.bulkInsertPlans(companions);
      }

      final rawEntries = doc['planEntries'];
      if (rawEntries is List) {
        final companions = rawEntries
            .cast<Map<String, dynamic>>()
            .map((m) => _planEntryFromMap(m).toCompanion(false))
            .toList();
        await _db.bulkInsertPlanEntries(companions);
      }
    }

    if (sections.contains(BackupSection.history)) {
      await _db.clearWorkoutSets();
      await _db.clearWorkoutSessions();

      final rawSessions = doc['sessions'];
      if (rawSessions is List) {
        final companions = rawSessions
            .cast<Map<String, dynamic>>()
            .map((m) => _sessionFromMap(m).toCompanion(false))
            .toList();
        await _db.bulkInsertWorkoutSessions(companions);
      }

      final rawSets = doc['workoutSets'];
      if (rawSets is List) {
        final companions = rawSets
            .cast<Map<String, dynamic>>()
            .map((m) => _workoutSetFromMap(m).toCompanion(false))
            .toList();
        await _db.bulkInsertWorkoutSets(companions);
      }
    }
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final backupServiceProvider = Provider<BackupService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return BackupService(db);
});
