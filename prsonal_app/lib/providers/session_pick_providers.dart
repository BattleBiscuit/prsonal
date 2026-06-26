import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/plans_service.dart';
import 'app_providers.dart';

export '../services/plans_service.dart'
    show PlanView, PlanEntryView, UnplannedRoutine;

/// Backing async provider — calls the real service.
final _activePlansViewFutureProvider = FutureProvider<List<PlanView>>((
  ref,
) async {
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
    final service = ref.watch(plansServiceProvider);
    return service.unplannedRoutines();
  },
);

/// Sync provider returning unplanned routines; override directly in tests.
final unplannedRoutinesProvider = Provider<List<UnplannedRoutine>>((ref) {
  return ref.watch(_unplannedRoutinesFutureProvider).valueOrNull ?? const [];
});
