import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/database/app_database.dart';
import 'package:prsonal_app/models/exercise.dart';
import 'package:prsonal_app/models/routine_exercise.dart';
import 'package:prsonal_app/models/workout_math.dart';
import 'package:prsonal_app/providers/app_providers.dart';
import 'package:prsonal_app/services/platform_service.dart';
import 'package:prsonal_app/services/session_service.dart';
import 'package:uuid/uuid.dart';

/// Seeds a routine with a single strength exercise of [setCount] sets and
/// returns its routineId. Helper is intentionally close to the implementation
/// API so the engine test reads as a behavioural contract.
Future<String> _seedRoutine(
  AppDatabase db, {
  int setCount = 2,
  double plannedWeight = 80,
  int reps = 8,
}) async {
  // 1. Insert a strength exercise.
  final exerciseId = await db.insertExercise(
    name: 'Bench Press',
    type: ExerciseType.strength,
  );

  // 2. Insert a routine.
  final routineId = await db.insertRoutine(name: 'Push Day A');

  // 3. Build the SetTarget list.
  final sets = List.generate(
    setCount,
    (_) => SetTarget.strength(
      reps: reps,
      weight: plannedWeight,
      isBodyweight: false,
      restSeconds: 90,
    ),
  );

  // 4. Insert the routine exercise linking exercise → routine with sets.
  await db.insertRoutineExerciseRow(
    RoutineExercisesCompanion.insert(
      id: const Uuid().v4(),
      routineId: routineId,
      exerciseId: exerciseId,
      position: 0,
      sets: sets,
    ),
  );

  return routineId;
}

void main() {
  late AppDatabase db;
  late FakePlatformService platform;
  late ProviderContainer container;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    platform = FakePlatformService();
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        platformServiceProvider.overrideWithValue(platform),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  SessionEngine engine() => container.read(sessionEngineProvider.notifier);
  ActiveSessionState state() => container.read(sessionEngineProvider)!;

  group('SessionService', () {
    test(
      'AC-001: startSession creates an active session and one workout set per planned set of the routine, with the cursor on the first set',
      () async {
        final routineId = await _seedRoutine(db, setCount: 3);
        await engine().startSession(routineId: routineId);
        expect(state().totalCount, 3);
        expect(state().cursor, (exerciseIndex: 0, setIndex: 0));
        final stored = await db.workoutSetsForSession(state().session.id);
        expect(stored.length, 3);
      },
    );

    test(
      'AC-002: resumeActiveSession restores an existing active session with the cursor at the first incomplete set, and returns false when none exists',
      () async {
        expect(await engine().resumeActiveSession(), isFalse);
        final routineId = await _seedRoutine(db, setCount: 2);
        await engine().startSession(routineId: routineId);
        await engine().markCurrentSetComplete(
          actualPrimary: 8,
          actualSecondary: 80,
          isBodyweight: false,
        );
        container.read(sessionEngineProvider.notifier).reset();
        expect(await engine().resumeActiveSession(), isTrue);
        expect(state().cursor.setIndex, 1);
      },
    );

    test(
      'AC-003: markCurrentSetComplete records the actual reps and weight, sets completedAt, and freezes effectiveWeight and estimated1RM',
      () async {
        final routineId = await _seedRoutine(db);
        await engine().startSession(routineId: routineId);
        await engine().markCurrentSetComplete(
          actualPrimary: 8,
          actualSecondary: 82.5,
          isBodyweight: false,
        );
        final set = (await db.workoutSetsForSession(state().session.id)).first;
        expect(set.actualReps, 8);
        expect(set.actualWeight, 82.5);
        expect(set.completedAt, isNotNull);
        expect(set.effectiveWeight, 82.5);
        expect(
          set.estimated1RM,
          closeTo(estimatedOneRepMax(effectiveWeight: 82.5, reps: 8), 1e-9),
        );
      },
    );

    test(
      'AC-004: a completed strength set whose estimated 1RM exceeds every prior set of that exercise is flagged isPR',
      () async {
        final routineId = await _seedRoutine(
          db,
          setCount: 2,
          plannedWeight: 80,
          reps: 8,
        );
        await engine().startSession(routineId: routineId);
        await engine().markCurrentSetComplete(
          actualPrimary: 8,
          actualSecondary: 80,
          isBodyweight: false,
        );
        await engine().markCurrentSetComplete(
          actualPrimary: 8,
          actualSecondary: 90,
          isBodyweight: false,
        );
        final sets = await db.workoutSetsForSession(state().session.id);
        expect(sets[1].isPR, isTrue);
      },
    );

    test(
      'AC-005: a completed strength set whose estimated 1RM does not exceed the prior best is not flagged isPR',
      () async {
        final routineId = await _seedRoutine(db, setCount: 2);
        await engine().startSession(routineId: routineId);
        await engine().markCurrentSetComplete(
          actualPrimary: 8,
          actualSecondary: 90,
          isBodyweight: false,
        );
        await engine().markCurrentSetComplete(
          actualPrimary: 8,
          actualSecondary: 80,
          isBodyweight: false,
        );
        final sets = await db.workoutSetsForSession(state().session.id);
        expect(sets[1].isPR, isFalse);
      },
    );

    test(
      'AC-006: markCurrentSetComplete advances the cursor to the next set',
      () async {
        final routineId = await _seedRoutine(db, setCount: 2);
        await engine().startSession(routineId: routineId);
        await engine().markCurrentSetComplete(
          actualPrimary: 8,
          actualSecondary: 80,
          isBodyweight: false,
        );
        expect(state().cursor.setIndex, 1);
      },
    );

    test(
      'AC-007: completing a PR set triggers a PR haptic and a non-PR set triggers a tap haptic',
      () async {
        final routineId = await _seedRoutine(db, setCount: 2);
        await engine().startSession(routineId: routineId);
        // First set is always a PR (no prior history).
        await engine().markCurrentSetComplete(
          actualPrimary: 8,
          actualSecondary: 90,
          isBodyweight: false,
        );
        expect(platform.hapticLog.last, 'pr');
        await engine().markCurrentSetComplete(
          actualPrimary: 8,
          actualSecondary: 50,
          isBodyweight: false,
        );
        expect(platform.hapticLog.last, 'tap');
      },
    );

    test(
      'AC-008: finishSession marks the session completed and writes the logged actuals back to the routine as new planned targets',
      () async {
        final routineId = await _seedRoutine(
          db,
          setCount: 1,
          plannedWeight: 80,
          reps: 8,
        );
        await engine().startSession(routineId: routineId);
        await engine().markCurrentSetComplete(
          actualPrimary: 10,
          actualSecondary: 85,
          isBodyweight: false,
        );
        final sessionId = state().session.id;
        await engine().finishSession();
        expect(container.read(sessionEngineProvider), isNull);
        final session = await db.sessionById(sessionId);
        expect(session!.status.name, 'completed');
        final updated = await db.setTargetsForRoutine(routineId);
        expect(updated.first.reps, 10);
        expect(updated.first.weight, 85);
      },
    );

    test(
      'AC-009: abandonSession deletes the session and all of its sets and clears the active state',
      () async {
        final routineId = await _seedRoutine(db);
        await engine().startSession(routineId: routineId);
        final sessionId = state().session.id;
        await engine().abandonSession();
        expect(container.read(sessionEngineProvider), isNull);
        expect(await db.sessionById(sessionId), isNull);
        expect(await db.workoutSetsForSession(sessionId), isEmpty);
      },
    );

    test(
      'AC-010: startRest schedules a rest-complete notification and cancelRest cancels it',
      () async {
        final routineId = await _seedRoutine(db);
        await engine().startSession(routineId: routineId);
        engine().startRest(90);
        expect(platform.pendingRest, const Duration(seconds: 90));
        engine().cancelRest();
        expect(platform.pendingRest, isNull);
      },
    );

    test(
      'AC-011: a mutating method called with no active session throws a StateError',
      () async {
        expect(
          () => engine().markCurrentSetComplete(
            actualPrimary: 8,
            actualSecondary: 80,
            isBodyweight: false,
          ),
          throwsStateError,
        );
      },
    );

    test(
      'AC-012: jumpToSet makes the selected set the only active set, reverting any previously active set to pending',
      () async {
        final routineId = await _seedRoutine(db, setCount: 3);
        await engine().startSession(routineId: routineId);
        // Set 0 starts active.
        expect(state().exercises[0].sets[0].status, ActiveSetStatus.active);

        engine().jumpToSet(0, 2);

        expect(state().cursor, (exerciseIndex: 0, setIndex: 2));
        expect(state().exercises[0].sets[2].status, ActiveSetStatus.active);
        // The previously active set is reverted to pending — exactly one active.
        expect(state().exercises[0].sets[0].status, ActiveSetStatus.pending);
        final activeCount = state().exercises.fold<int>(
          0,
          (sum, ex) =>
              sum +
              ex.sets
                  .where((s) => s.status == ActiveSetStatus.active)
                  .length,
        );
        expect(activeCount, 1);
      },
    );
  });
}
