import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/plans_service.dart';
import 'app_providers.dart';

export '../services/plans_service.dart'
    show PlanView, PlanEntryView, UnplannedRoutine;

// ---------------------------------------------------------------------------
// Change-signal streams.
//
// The session-pick view is derived from plans, plan entries, routines, and
// completed sessions. The backing future providers below watch these streams
// so the view recomputes whenever any of that underlying data changes —
// without this, the futures would compute once (e.g. against an empty DB at
// launch) and never refresh, leaving the screen permanently empty.
// ---------------------------------------------------------------------------

final _plansChangedProvider = StreamProvider((ref) {
  return ref.watch(appDatabaseProvider).watchAllPlans();
});

final _planEntriesChangedProvider = StreamProvider((ref) {
  return ref.watch(appDatabaseProvider).watchAllPlanEntries();
});

final _routinesChangedProvider = StreamProvider((ref) {
  return ref.watch(appDatabaseProvider).watchAllRoutines();
});

final _completedSessionsChangedProvider = StreamProvider((ref) {
  return ref.watch(appDatabaseProvider).watchCompletedSessions();
});

/// Backing async provider — calls the real service.
final _activePlansViewFutureProvider = FutureProvider<List<PlanView>>((
  ref,
) async {
  // React to any change in the underlying data.
  ref.watch(_plansChangedProvider);
  ref.watch(_planEntriesChangedProvider);
  ref.watch(_routinesChangedProvider);
  ref.watch(_completedSessionsChangedProvider);

  final service = ref.watch(plansServiceProvider);
  final now = ref.read(nowProvider)();
  return service.activePlansView(asOf: now);
});

/// Sync provider returning the active plans list; override directly in tests.
final activePlansViewProvider = Provider<List<PlanView>>((ref) {
  return ref.watch(_activePlansViewFutureProvider).valueOrNull ?? const [];
});

/// Backing async provider — calls the real service.
final _unplannedRoutinesFutureProvider = FutureProvider<List<UnplannedRoutine>>(
  (ref) async {
    // React to any change in the underlying data.
    ref.watch(_plansChangedProvider);
    ref.watch(_planEntriesChangedProvider);
    ref.watch(_routinesChangedProvider);

    final service = ref.watch(plansServiceProvider);
    return service.unplannedRoutines();
  },
);

/// Sync provider returning unplanned routines; override directly in tests.
final unplannedRoutinesProvider = Provider<List<UnplannedRoutine>>((ref) {
  return ref.watch(_unplannedRoutinesFutureProvider).valueOrNull ?? const [];
});
