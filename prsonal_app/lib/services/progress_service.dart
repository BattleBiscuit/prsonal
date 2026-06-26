import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../models/exercise.dart';
import '../models/plan.dart';
import '../providers/app_providers.dart';

// ---------------------------------------------------------------------------
// Enums / View-model types
// ---------------------------------------------------------------------------

/// How muscle frequency is counted across a range.
enum MuscleMode {
  /// Deduplicate per exercise: each muscle is counted once per unique exercise.
  exercise,

  /// Deduplicate per session: each muscle is counted once per session.
  session,
}

/// A personal-record item for one exercise.
class PRItem {
  const PRItem({
    required this.exerciseName,
    required this.oneRepMax,
    required this.reps,
    required this.weight,
    required this.isBodyweight,
    required this.date,
  });

  final String exerciseName;
  final double oneRepMax;
  final int reps;
  final double weight;
  final bool isBodyweight;
  final DateTime date;
}

// ---------------------------------------------------------------------------
// ProgressService
// ---------------------------------------------------------------------------

class ProgressService {
  ProgressService(this._db);

  final AppDatabase _db;

  // -------------------------------------------------------------------------
  // workoutCount — sessions started within [rangeDays] ending at [asOf]
  // -------------------------------------------------------------------------

  Future<int> workoutCount(int rangeDays, {required DateTime asOf}) async {
    final from = asOf.subtract(Duration(days: rangeDays));
    final sessions = await _db.completedSessionsInRange(from, asOf);
    return sessions.length;
  }

  // -------------------------------------------------------------------------
  // sessionVolumes — one record per session with summed volume
  // -------------------------------------------------------------------------

  Future<List<({String label, double volume, String routineName})>>
  sessionVolumes(int rangeDays, {required DateTime asOf}) async {
    final from = asOf.subtract(Duration(days: rangeDays));
    final sessions = await _db.completedSessionsInRange(from, asOf);

    final result = <({String label, double volume, String routineName})>[];
    for (final session in sessions) {
      final sets = await _db.workoutSetsForSession(session.id);
      double vol = 0;
      for (final s in sets) {
        if (!s.skipped && s.actualReps != null && s.effectiveWeight != null) {
          vol += s.actualReps! * s.effectiveWeight!;
        }
      }
      result.add((
        label: session.startedAt.toIso8601String().substring(0, 10),
        volume: vol,
        routineName: session.routineName,
      ));
    }
    return result;
  }

  // -------------------------------------------------------------------------
  // volumeTrendPercent — percent change first half vs second half
  // -------------------------------------------------------------------------

  Future<double?> volumeTrendPercent(
    int rangeDays, {
    required DateTime asOf,
  }) async {
    final vols = await sessionVolumes(rangeDays, asOf: asOf);
    if (vols.length < 2) return null;

    final half = vols.length ~/ 2;
    // Sessions are returned newest-first; so the second half (older) is
    // vols[half..end] and first half (newer) is vols[0..half].
    final newerVol = vols.take(half).fold(0.0, (sum, v) => sum + v.volume);
    final olderVol = vols.skip(half).fold(0.0, (sum, v) => sum + v.volume);

    if (olderVol == 0) return null;
    return (newerVol - olderVol) / olderVol * 100.0;
  }

  // -------------------------------------------------------------------------
  // muscleFrequency
  // -------------------------------------------------------------------------

  Future<List<({Muscle muscle, double count})>> muscleFrequency(
    int rangeDays,
    MuscleMode mode, {
    required DateTime asOf,
  }) async {
    final from = asOf.subtract(Duration(days: rangeDays));
    final sessions = await _db.completedSessionsInRange(from, asOf);

    // Map muscle → cumulative count.
    final muscleCount = <Muscle, double>{};

    for (final session in sessions) {
      final sets = await _db.workoutSetsForSession(session.id);

      if (mode == MuscleMode.exercise) {
        // Deduplicate by (exerciseId or exerciseName).
        final seenExercises = <String>{};
        for (final s in sets) {
          final key = s.exerciseId ?? s.exerciseName;
          if (seenExercises.contains(key)) continue;
          seenExercises.add(key);

          final exerciseRow = s.exerciseId != null
              ? await _db.exerciseById(s.exerciseId!)
              : null;
          if (exerciseRow == null) continue;

          for (final m in exerciseRow.primaryMuscles) {
            muscleCount[m] = (muscleCount[m] ?? 0) + 1.0;
          }
          for (final m in exerciseRow.secondaryMuscles) {
            muscleCount[m] = (muscleCount[m] ?? 0) + 0.5;
          }
        }
      } else {
        // session mode: deduplicate per session
        final sessionPrimary = <Muscle>{};
        final sessionSecondary = <Muscle>{};

        for (final s in sets) {
          final exerciseRow = s.exerciseId != null
              ? await _db.exerciseById(s.exerciseId!)
              : null;
          if (exerciseRow == null) continue;

          for (final m in exerciseRow.primaryMuscles) {
            sessionPrimary.add(m);
          }
          for (final m in exerciseRow.secondaryMuscles) {
            if (!sessionPrimary.contains(m)) sessionSecondary.add(m);
          }
        }

        for (final m in sessionPrimary) {
          muscleCount[m] = (muscleCount[m] ?? 0) + 1.0;
        }
        for (final m in sessionSecondary) {
          muscleCount[m] = (muscleCount[m] ?? 0) + 0.5;
        }
      }
    }

    return muscleCount.entries
        .map((e) => (muscle: e.key, count: e.value))
        .toList();
  }

  // -------------------------------------------------------------------------
  // allPRs — best set per exercise ranked by 1RM
  // -------------------------------------------------------------------------

  Future<List<PRItem>> allPRs() async {
    // Get all PR sets; find best per exercise name.
    final allSets =
        await (_db.select(_db.workoutSets)
              ..where((s) => s.isPR.equals(true))
              ..orderBy([(s) => OrderingTerm.desc(s.estimated1RM)]))
            .get();

    final byExercise = <String, WorkoutSet>{};
    for (final s in allSets) {
      final key = s.exerciseName;
      final existing = byExercise[key];
      final sVal = s.estimated1RM ?? 0.0;
      final existingVal = existing?.estimated1RM ?? -1.0;
      if (sVal > existingVal) {
        byExercise[key] = s;
      }
    }

    return byExercise.values.map(_toPRItem).toList()
      ..sort((a, b) => b.oneRepMax.compareTo(a.oneRepMax));
  }

  // -------------------------------------------------------------------------
  // recentPRs — PR sets in range, newest first
  // -------------------------------------------------------------------------

  Future<List<PRItem>> recentPRs(
    int rangeDays, {
    required DateTime asOf,
  }) async {
    final from = asOf.subtract(Duration(days: rangeDays));
    final sessions = await _db.completedSessionsInRange(from, asOf);
    final sessionIds = sessions.map((s) => s.id).toList();
    final prSets = await _db.prSetsInSessionRange(sessionIds);
    // Re-order by date, newest first.
    final sorted = List<WorkoutSet>.from(prSets)
      ..sort((a, b) {
        final aDate = a.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
    return sorted.map(_toPRItem).toList();
  }

  // -------------------------------------------------------------------------
  // bestLifts — top lifts by 1RM, limited
  // -------------------------------------------------------------------------

  Future<List<PRItem>> bestLifts({required int limit}) async {
    final prs = await allPRs();
    return prs.take(limit).toList();
  }

  // -------------------------------------------------------------------------
  // planAdherencePercent
  // -------------------------------------------------------------------------

  Future<double?> planAdherencePercent(
    int rangeDays, {
    required DateTime asOf,
  }) async {
    final from = asOf.subtract(Duration(days: rangeDays));

    // Get all active plans.
    final allPlans = await _db.allPlans();
    final activePlans = allPlans
        .where((p) => p.status == PlanStatus.active)
        .toList();
    if (activePlans.isEmpty) return null;

    int required = 0;
    int completed = 0;

    // Sessions in range.
    final sessionsInRange = await _db.completedSessionsInRange(from, asOf);
    final completedEntryIds = sessionsInRange
        .map((s) => s.planEntryId)
        .whereType<String>()
        .toSet();

    for (final plan in activePlans) {
      final entries = await _db.planEntriesForPlan(plan.id);
      // Each plan entry that has a scheduled day counts as required once per
      // week in the range.
      final scheduledEntries = entries
          .where((e) => e.dayOfWeek != null)
          .toList();
      if (scheduledEntries.isEmpty) continue;

      final weeks = (rangeDays / 7).ceil();
      required += scheduledEntries.length * weeks;
      completed += completedEntryIds
          .where((id) => scheduledEntries.any((e) => e.id == id))
          .length;
    }

    if (required == 0) return null;
    return completed / required * 100.0;
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  PRItem _toPRItem(WorkoutSet s) {
    return PRItem(
      exerciseName: s.exerciseName,
      oneRepMax: s.estimated1RM ?? 0.0,
      reps: s.actualReps ?? 0,
      weight: s.actualWeight ?? 0.0,
      isBodyweight: s.isBodyweight,
      date: s.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final progressServiceProvider = Provider<ProgressService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ProgressService(db);
});
