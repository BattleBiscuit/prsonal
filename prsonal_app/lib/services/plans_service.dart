import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../models/plan.dart';
import '../providers/app_providers.dart';
import 'service_exceptions.dart';

export 'service_exceptions.dart' show NotFoundException;
export '../models/plan.dart' show PlanStatus;

// ---------------------------------------------------------------------------
// View-model types
// ---------------------------------------------------------------------------

/// One entry in a [PlanDraft] — plan edit screen.
class PlanEntryDraft {
  const PlanEntryDraft({
    required this.id,
    required this.routineId,
    required this.routineName,
    this.dayOfWeek,
    this.order = 0,
  });

  final String id;
  final String routineId;
  final String routineName;
  final int? dayOfWeek;
  final int order;
}

/// Full plan data for the edit screen.
class PlanDraft {
  const PlanDraft({
    required this.id,
    required this.name,
    required this.entries,
  });

  final String id;
  final String name;
  final List<PlanEntryDraft> entries;
}

/// Input value object for [PlansService.replaceEntries].
class PlanEntryInput {
  const PlanEntryInput({required this.routineId, this.dayOfWeek});

  final String routineId;
  final int? dayOfWeek;
}

/// Entry row in an active-plans view.
class PlanEntryView {
  const PlanEntryView({
    required this.entryId,
    required this.routineId,
    required this.routineName,
    this.dayLabel,
    required this.doneThisWeek,
  });

  final String entryId;
  final String routineId;
  final String routineName;
  final String? dayLabel;
  final bool doneThisWeek;
}

/// Active-plan summary shown on the session-pick screen.
class PlanView {
  const PlanView({
    required this.id,
    required this.name,
    required this.streak,
    required this.entries,
  });

  final String id;
  final String name;
  final int streak;
  final List<PlanEntryView> entries;
}

/// Routine not referenced by any active plan.
class UnplannedRoutine {
  const UnplannedRoutine({required this.id, required this.name});

  final String id;
  final String name;
}

// ---------------------------------------------------------------------------
// Day-of-week labels (ISO weekday: Mon=1 ... Sun=7)
// dayOfWeek stored in DB uses 0-based Mon=0 ... Sun=6
// ---------------------------------------------------------------------------

const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

String? _dayLabel(int? dayOfWeek) {
  if (dayOfWeek == null) return null;
  if (dayOfWeek < 0 || dayOfWeek > 6) return null;
  return _dayLabels[dayOfWeek];
}

// ---------------------------------------------------------------------------
// PlansService
// ---------------------------------------------------------------------------

class PlansService {
  PlansService(this._db);

  final AppDatabase _db;
  static final _uuid = Uuid();

  // -------------------------------------------------------------------------
  // watchPlans — active plans by order
  // -------------------------------------------------------------------------

  Stream<List<Plan>> watchPlans() {
    return _db.watchAllPlans();
  }

  // -------------------------------------------------------------------------
  // getPlanForEdit — throws NotFoundException if not found
  // -------------------------------------------------------------------------

  Future<PlanDraft> getPlanForEdit(String id) async {
    final plan = await _db.planById(id);
    if (plan == null) throw const NotFoundException();

    final entryRows = await _db.planEntriesForPlan(id);
    final routineIds = entryRows.map((e) => e.routineId).toSet().toList();
    final nameMap = await _resolveRoutineNames(routineIds);

    final entries = entryRows.map((e) {
      return PlanEntryDraft(
        id: e.id,
        routineId: e.routineId,
        routineName: nameMap[e.routineId] ?? '',
        dayOfWeek: e.dayOfWeek,
        order: e.order,
      );
    }).toList();

    return PlanDraft(id: plan.id, name: plan.name, entries: entries);
  }

  // -------------------------------------------------------------------------
  // createPlan — inserts an active plan at next order, returns id
  // -------------------------------------------------------------------------

  Future<String> createPlan(String name) async {
    final id = _uuid.v4();
    final allPlans = await _db.allPlans();
    final nextOrder = allPlans.isEmpty
        ? 0
        : allPlans.map((p) => p.order).reduce((a, b) => a > b ? a : b) + 1;

    await _db.insertPlanRow(
      PlansCompanion.insert(
        id: id,
        name: name,
        status: PlanStatus.active,
        order: nextOrder,
        createdAt: DateTime.now(),
      ),
    );
    return id;
  }

  // -------------------------------------------------------------------------
  // updatePlan
  // -------------------------------------------------------------------------

  Future<void> updatePlan(String id, {String? name, PlanStatus? status}) async {
    final existing = await _db.planById(id);
    if (existing == null) throw const NotFoundException();

    await _db.updatePlanRow(
      PlansCompanion(
        id: Value(id),
        name: Value(name ?? existing.name),
        status: Value(status ?? existing.status),
        order: Value(existing.order),
        createdAt: Value(existing.createdAt),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // deletePlan — deletes plan + entries (cascade would handle entries but let's be explicit)
  // -------------------------------------------------------------------------

  Future<void> deletePlan(String id) async {
    await _db.deletePlanEntriesForPlan(id);
    await _db.deletePlanById(id);
  }

  // -------------------------------------------------------------------------
  // replaceEntries — delete and re-insert
  // -------------------------------------------------------------------------

  Future<void> replaceEntries(
    String planId,
    List<PlanEntryInput> entries,
  ) async {
    await _db.deletePlanEntriesForPlan(planId);
    for (var i = 0; i < entries.length; i++) {
      final e = entries[i];
      await _db.insertPlanEntryRow(
        PlanEntriesCompanion.insert(
          id: _uuid.v4(),
          planId: planId,
          routineId: e.routineId,
          dayOfWeek: Value(e.dayOfWeek),
          order: i,
        ),
      );
    }
  }

  // -------------------------------------------------------------------------
  // activePlansView — with entries, day labels, done-this-week, streak
  // -------------------------------------------------------------------------

  Future<List<PlanView>> activePlansView({required DateTime asOf}) async {
    final allPlans = await _db.allPlans();
    final activePlans = allPlans
        .where((p) => p.status == PlanStatus.active)
        .toList();

    // Compute week boundaries for asOf (Mon–Sun, ISO).
    final weekStart = _weekStart(asOf);
    // weekEnd is exclusive (next Monday), so subtract 1ms for the inclusive DB query.
    final weekEnd = weekStart
        .add(const Duration(days: 7))
        .subtract(const Duration(seconds: 1));

    // Load completed sessions in the current week.
    final sessionsThisWeek = await _db.completedSessionsInRange(
      weekStart,
      weekEnd,
    );
    final completedEntryIds = sessionsThisWeek
        .map((s) => s.planEntryId)
        .whereType<String>()
        .toSet();

    final result = <PlanView>[];
    for (final plan in activePlans) {
      final entryRows = await _db.planEntriesForPlan(plan.id);
      final routineIds = entryRows.map((e) => e.routineId).toSet().toList();
      final nameMap = await _resolveRoutineNames(routineIds);

      final entryViews = entryRows.map((e) {
        return PlanEntryView(
          entryId: e.id,
          routineId: e.routineId,
          routineName: nameMap[e.routineId] ?? '',
          dayLabel: _dayLabel(e.dayOfWeek),
          doneThisWeek: completedEntryIds.contains(e.id),
        );
      }).toList();

      final streak = await streakForPlan(plan.id, asOf: asOf);

      result.add(
        PlanView(
          id: plan.id,
          name: plan.name,
          streak: streak,
          entries: entryViews,
        ),
      );
    }
    return result;
  }

  // -------------------------------------------------------------------------
  // unplannedRoutines — routines not referenced by any active plan
  // -------------------------------------------------------------------------

  Future<List<UnplannedRoutine>> unplannedRoutines() async {
    // Collect all routine ids referenced by active plans.
    final allPlans = await _db.allPlans();
    final activePlans = allPlans.where((p) => p.status == PlanStatus.active);
    final plannedRoutineIds = <String>{};
    for (final plan in activePlans) {
      final entries = await _db.planEntriesForPlan(plan.id);
      for (final e in entries) {
        plannedRoutineIds.add(e.routineId);
      }
    }

    final allRoutines = await _db.allRoutines();
    return allRoutines
        .where((r) => !plannedRoutineIds.contains(r.id))
        .map((r) => UnplannedRoutine(id: r.id, name: r.name))
        .toList();
  }

  // -------------------------------------------------------------------------
  // streakForPlan — consecutive complete weeks ending at asOf week
  // -------------------------------------------------------------------------

  Future<int> streakForPlan(String planId, {required DateTime asOf}) async {
    final entryRows = await _db.planEntriesForPlan(planId);
    // Only entries with a dayOfWeek matter for streak calculation.
    final scheduledEntries = entryRows
        .where((e) => e.dayOfWeek != null)
        .toList();
    if (scheduledEntries.isEmpty) return 0;

    int streak = 0;
    DateTime checkWeekStart = _weekStart(asOf);

    while (true) {
      // weekEnd is the Monday of the NEXT week — exclusive upper bound.
      // We use (weekStart, weekEnd-1ms) for inclusive DB queries.
      final checkWeekEnd = checkWeekStart.add(const Duration(days: 7));
      final isCurrentWeek = checkWeekStart == _weekStart(asOf);

      // For the current week, only count entries whose dayOfWeek <= asOf.weekday-1
      // (dayOfWeek is 0-based Mon=0, DateTime.weekday is 1-based Mon=1)
      final asOfDayIndex = asOf.weekday - 1; // 0=Mon ... 6=Sun

      final relevantEntries = isCurrentWeek
          ? scheduledEntries.where((e) => e.dayOfWeek! <= asOfDayIndex).toList()
          : scheduledEntries;

      if (relevantEntries.isEmpty) {
        // No scheduled entries relevant for this week — don't count it, stop.
        break;
      }

      // Load sessions for this week. Use checkWeekEnd-1ms to make the range
      // exclusive on the upper bound (next Monday belongs to the next week).
      final sessionsThisWeek = await _db.completedSessionsInRange(
        checkWeekStart,
        checkWeekEnd.subtract(const Duration(seconds: 1)),
      );
      final completedEntryIds = sessionsThisWeek
          .where((s) => s.planEntryId != null)
          .map((s) => s.planEntryId!)
          .toSet();

      // A week is "complete" when every relevant entry has a completed session.
      final allComplete = relevantEntries.every(
        (e) => completedEntryIds.contains(e.id),
      );

      if (allComplete) {
        streak++;
        checkWeekStart = checkWeekStart.subtract(const Duration(days: 7));
      } else {
        break;
      }
    }

    return streak;
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  Future<Map<String, String>> _resolveRoutineNames(
    List<String> routineIds,
  ) async {
    final nameMap = <String, String>{};
    for (final routineId in routineIds) {
      final routine = await _db.routineById(routineId);
      if (routine != null) nameMap[routineId] = routine.name;
    }
    return nameMap;
  }

  /// Returns the Monday 00:00:00 of the ISO week containing [dt].
  DateTime _weekStart(DateTime dt) {
    // DateTime.weekday: Mon=1, ..., Sun=7
    final daysSinceMonday = dt.weekday - 1;
    final monday = dt.subtract(Duration(days: daysSinceMonday));
    return DateTime(monday.year, monday.month, monday.day);
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final plansServiceProvider = Provider<PlansService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return PlansService(db);
});
