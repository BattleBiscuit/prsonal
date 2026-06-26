import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../models/exercise.dart';
import '../models/workout_math.dart';
import '../models/workout_session.dart';
import '../providers/app_providers.dart';
import '../widgets/history_set_table_widget.dart';
import 'service_exceptions.dart';

export 'service_exceptions.dart' show NotFoundException;
export '../widgets/history_set_table_widget.dart' show SetTableRow;

// ---------------------------------------------------------------------------
// View-model types
// ---------------------------------------------------------------------------

/// One exercise block inside a [SessionDetail].
/// [sets] is typed as [SetTableRow] so it can be consumed directly by the
/// history-set-table widget and constructed in screen tests.
class DetailExercise {
  const DetailExercise({
    required this.name,
    required this.sets,
  });

  final String name;
  final List<SetTableRow> sets;
}

/// Summary row for the history list.
class SessionSummary {
  const SessionSummary({
    required this.id,
    required this.routineName,
    required this.startedAt,
    required this.durationLabel,
    required this.volume,
    required this.abandoned,
  });

  final String id;
  final String routineName;
  final DateTime startedAt;
  final String durationLabel;
  final double volume;
  final bool abandoned;
}

/// Full session detail for the detail screen.
class SessionDetail {
  const SessionDetail({
    required this.id,
    required this.routineName,
    required this.startedAt,
    required this.durationLabel,
    required this.volume,
    required this.abandoned,
    required this.exercises,
    required this.prNames,
  });

  final String id;
  final String routineName;
  final DateTime startedAt;
  final String durationLabel;
  final double volume;
  final bool abandoned;
  final List<DetailExercise> exercises;
  final List<String> prNames;
}

// ---------------------------------------------------------------------------
// HistoryService
// ---------------------------------------------------------------------------

class HistoryService {
  HistoryService(this._db);

  final AppDatabase _db;

  // -------------------------------------------------------------------------
  // count
  // -------------------------------------------------------------------------

  Future<int> count() => _db.completedSessionCount();

  // -------------------------------------------------------------------------
  // loadPage — newest-first paged list of session summaries
  // -------------------------------------------------------------------------

  Future<List<SessionSummary>> loadPage({
    required int page,
    required int pageSize,
  }) async {
    final offset = (page - 1) * pageSize;
    final rows = await _db.completedSessions(limit: pageSize, offset: offset);
    final result = <SessionSummary>[];
    for (final row in rows) {
      final sets = await _db.workoutSetsForSession(row.id);
      final volume = _computeVolume(sets);
      result.add(SessionSummary(
        id: row.id,
        routineName: row.routineName,
        startedAt: row.startedAt,
        durationLabel: formatSessionDuration(row.startedAt, row.completedAt),
        volume: volume,
        abandoned: sessionIsAbandoned(
            status: row.status, totalVolume: volume),
      ));
    }
    return result;
  }

  // -------------------------------------------------------------------------
  // getDetail — throws NotFoundException for unknown id
  // -------------------------------------------------------------------------

  Future<SessionDetail> getDetail(String id) async {
    final row = await _db.sessionById(id);
    if (row == null) throw const NotFoundException();

    final sets = await _db.workoutSetsForSession(id);
    final volume = _computeVolume(sets);

    // Group by exercisePosition (already ordered by position, then index).
    final byPosition = <int, List<WorkoutSet>>{};
    for (final s in sets) {
      byPosition.putIfAbsent(s.exercisePosition, () => []).add(s);
    }

    final sortedPositions = byPosition.keys.toList()..sort();
    final exercises = <DetailExercise>[];
    final prNames = <String>[];

    for (final pos in sortedPositions) {
      final posSets = byPosition[pos]!;
      // Already sorted by setIndex from the query.
      final exerciseName = posSets.first.exerciseName;

      final detailSets = posSets.map((s) {
        String? actualLabel;
        if (!s.skipped && (s.actualReps != null || s.actualWeight != null)) {
          final reps = s.actualReps ?? 0;
          final weight = s.actualWeight ?? 0.0;
          actualLabel = '$reps×${weight}kg';
        }
        final plannedLabel = s.type == ExerciseType.strength
            ? '${s.plannedReps ?? 0}×${s.plannedWeight ?? 0}kg'
            : '${s.plannedDuration ?? 0}s';
        return SetTableRow(
          id: s.id,
          setIndex: s.setIndex,
          plannedLabel: plannedLabel,
          actualLabel: actualLabel,
          skipped: s.skipped,
          isPR: s.isPR,
          kind: s.type,
        );
      }).toList();

      exercises.add(DetailExercise(name: exerciseName, sets: detailSets));

      if (posSets.any((s) => s.isPR)) {
        prNames.add(exerciseName);
      }
    }

    return SessionDetail(
      id: row.id,
      routineName: row.routineName,
      startedAt: row.startedAt,
      durationLabel: formatSessionDuration(row.startedAt, row.completedAt),
      volume: volume,
      abandoned: sessionIsAbandoned(status: row.status, totalVolume: volume),
      exercises: exercises,
      prNames: prNames,
    );
  }

  // -------------------------------------------------------------------------
  // deleteSession
  // -------------------------------------------------------------------------

  Future<void> deleteSession(String id) async {
    await _db.deleteWorkoutSessionById(id);
  }

  // -------------------------------------------------------------------------
  // updateSetActuals
  // -------------------------------------------------------------------------

  Future<void> updateSetActuals(
    String setId, {
    int? reps,
    double? weight,
    bool? isBodyweight,
    bool? skipped,
  }) async {
    // Load existing set — we need session context for the full update.
    final existing = await (_db.select(_db.workoutSets)
          ..where((s) => s.id.equals(setId)))
        .getSingleOrNull();
    if (existing == null) return;

    final effectiveReps = reps ?? existing.actualReps;
    final effectiveWeightVal = weight ?? existing.effectiveWeight;

    double? newEffectiveWeight;
    double? newEstimated1RM;

    if (effectiveReps != null && effectiveWeightVal != null) {
      // effectiveWeight is the weight as-stored (already resolved from BW
      // during the session). If we receive a new raw weight and isBodyweight,
      // we store it directly as effectiveWeight since we don't have bodyweight
      // available here.  The caller passes the resolved weight.
      newEffectiveWeight = effectiveWeightVal;
      newEstimated1RM = estimatedOneRepMax(
        effectiveWeight: newEffectiveWeight,
        reps: effectiveReps,
      );
    }

    await _db.updateWorkoutSetRow(WorkoutSetsCompanion(
      id: Value(setId),
      sessionId: Value(existing.sessionId),
      exercisePosition: Value(existing.exercisePosition),
      exerciseName: Value(existing.exerciseName),
      setIndex: Value(existing.setIndex),
      type: Value(existing.type),
      actualReps: Value(effectiveReps),
      actualWeight: Value(weight ?? existing.actualWeight),
      effectiveWeight: Value(newEffectiveWeight),
      estimated1RM: Value(newEstimated1RM),
      skipped: Value(skipped ?? existing.skipped),
    ));
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  double _computeVolume(List<WorkoutSet> sets) {
    double total = 0;
    for (final s in sets) {
      if (!s.skipped &&
          s.actualReps != null &&
          s.effectiveWeight != null) {
        total += s.actualReps! * s.effectiveWeight!;
      }
    }
    return total;
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final historyServiceProvider = Provider<HistoryService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return HistoryService(db);
});
