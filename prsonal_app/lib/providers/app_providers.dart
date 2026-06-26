import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import '../services/library_service.dart';
import '../services/plans_service.dart';
import '../services/routines_service.dart';
import '../widgets/exercise_search_input_widget.dart';

export '../services/routines_service.dart'
    show RoutineSummary, RoutineDraft, RoutineExerciseDraft;
export '../services/library_service.dart' show LibraryExercise;
export '../services/plans_service.dart'
    show PlanDraft, PlanEntryDraft, PlanEntryInput;

/// Provides the singleton [AppDatabase] instance.
///
/// Override this in tests with [AppDatabase.forTesting].
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// Provides a factory that returns the current [DateTime].
///
/// Override this in tests to inject a fixed clock.
final nowProvider = Provider<DateTime Function()>((ref) => DateTime.now);

// ---------------------------------------------------------------------------
// Routines
// ---------------------------------------------------------------------------

/// Stream of all routines; override with StreamProvider.overrideWith in tests.
final routinesListProvider = StreamProvider<List<RoutineSummary>>((ref) {
  final service = ref.watch(routinesServiceProvider);
  return service.watchRoutines();
});

/// Draft for a single routine (null = create mode).
final routineDraftProvider = FutureProvider.family<RoutineDraft?, String?>((
  ref,
  routineId,
) async {
  if (routineId == null) return null;
  final service = ref.watch(routinesServiceProvider);
  return service.getRoutineForEdit(routineId);
});

// ---------------------------------------------------------------------------
// Library
// ---------------------------------------------------------------------------

/// Stream of all library exercises.
final libraryListProvider = StreamProvider<List<LibraryExercise>>((ref) {
  final service = ref.watch(libraryServiceProvider);
  return service.watchExercises();
});

/// Stream of ExerciseOption (for ExerciseForm picker).
final libraryOptionsProvider = StreamProvider<List<ExerciseOption>>((
  ref,
) async* {
  final service = ref.watch(libraryServiceProvider);
  await for (final exercises in service.watchExercises()) {
    yield exercises
        .map(
          (e) => ExerciseOption(
            id: e.id,
            name: e.name,
            type: e.type,
            primaryMuscles: e.primaryMuscles,
          ),
        )
        .toList();
  }
});

// ---------------------------------------------------------------------------
// Plans
// ---------------------------------------------------------------------------

/// Draft for a single plan (null = create mode).
final planDraftProvider = FutureProvider.family<PlanDraft?, String?>((
  ref,
  planId,
) async {
  if (planId == null) return null;
  final service = ref.watch(plansServiceProvider);
  return service.getPlanForEdit(planId);
});

// ---------------------------------------------------------------------------
// App meta
// ---------------------------------------------------------------------------

/// App version string. Override in tests.
final appVersionProvider = Provider<String>((ref) => '1.0.0');

/// A function that presents a file picker and returns the JSON string or null.
/// Override in tests with a stub.
final backupFilePickerProvider = Provider<Future<String?> Function()>(
  (ref) =>
      () async => null,
);
