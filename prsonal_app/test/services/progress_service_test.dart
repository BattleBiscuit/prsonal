import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/database/app_database.dart';
import 'package:prsonal_app/models/exercise.dart';
import 'package:prsonal_app/models/plan.dart';
import 'package:prsonal_app/models/workout_math.dart';
import 'package:prsonal_app/providers/app_providers.dart';
import 'package:prsonal_app/services/progress_service.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late ProgressService service;
  final asOf = DateTime(2026, 6, 24);

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    service = container.read(progressServiceProvider);
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  SeedSet bench({
    required int index,
    required int reps,
    required double weight,
    bool isPR = false,
  }) => SeedSet(
    exercisePosition: 0,
    exerciseName: 'Bench',
    exerciseId: 'eBench',
    setIndex: index,
    type: ExerciseType.strength,
    actualReps: reps,
    actualWeight: weight,
    effectiveWeight: weight,
    estimated1RM: estimatedOneRepMax(effectiveWeight: weight, reps: reps),
    completedAt: asOf,
    skipped: false,
    isPR: isPR,
  );

  group('ProgressService', () {
    test(
      'AC-001: workoutCount returns the number of completed sessions started within the range',
      () async {
        await db.seedCompletedSession(
          routineId: 'r1',
          routineName: 'A',
          startedAt: DateTime(2026, 6, 23),
        );
        await db.seedCompletedSession(
          routineId: 'r1',
          routineName: 'A',
          startedAt: DateTime(2026, 1, 1),
        );
        expect(await service.workoutCount(28, asOf: asOf), 1);
      },
    );

    test(
      'AC-002: sessionVolumes returns one entry per completed session with its summed volume (actualReps × effectiveWeight)',
      () async {
        await db.seedCompletedSession(
          routineId: 'r1',
          routineName: 'A',
          startedAt: DateTime(2026, 6, 23),
          sets: [
            bench(index: 0, reps: 10, weight: 80),
            bench(index: 1, reps: 10, weight: 80),
          ],
        );
        final vols = await service.sessionVolumes(28, asOf: asOf);
        expect(vols.single.volume, 1600);
      },
    );

    test(
      'AC-003: volumeTrendPercent returns the percent change between the first and second half of the range, or null when there is too little data',
      () async {
        // Fewer than 2 sessions in range → null, can't compute a trend.
        expect(await service.volumeTrendPercent(28, asOf: asOf), isNull);

        // Newer session: 15 reps × 100kg = 1500kg. Older: 10 reps × 100kg =
        // 1000kg. (1500 - 1000) / 1000 * 100 = 50%.
        await db.seedCompletedSession(
          routineId: 'r1',
          routineName: 'A',
          startedAt: DateTime(2026, 6, 20),
          sets: [bench(index: 0, reps: 10, weight: 100)],
        );
        await db.seedCompletedSession(
          routineId: 'r1',
          routineName: 'A',
          startedAt: DateTime(2026, 6, 23),
          sets: [bench(index: 0, reps: 15, weight: 100)],
        );
        expect(
          await service.volumeTrendPercent(28, asOf: asOf),
          closeTo(50.0, 1e-9),
        );
      },
    );

    test(
      'AC-004: muscleFrequency counts primary muscles at 1.0 and secondary at 0.5, joined from the exercise library',
      () async {
        await db.insertExerciseWithId(
          'eBench',
          name: 'Bench',
          type: ExerciseType.strength,
          primaryMuscles: [Muscle.chest],
          secondaryMuscles: [Muscle.arms],
        );
        await db.seedCompletedSession(
          routineId: 'r1',
          routineName: 'A',
          startedAt: DateTime(2026, 6, 23),
          sets: [bench(index: 0, reps: 10, weight: 80)],
        );
        final freq = await service.muscleFrequency(
          28,
          MuscleMode.exercise,
          asOf: asOf,
        );
        final byMuscle = {for (final f in freq) f.muscle: f.count};
        expect(byMuscle[Muscle.chest], 1.0);
        expect(byMuscle[Muscle.arms], 0.5);
      },
    );

    test(
      'AC-005: allPRs returns the single best set per exercise ranked by estimated 1RM',
      () async {
        await db.seedCompletedSession(
          routineId: 'r1',
          routineName: 'A',
          startedAt: DateTime(2026, 6, 23),
          sets: [
            bench(index: 0, reps: 5, weight: 80, isPR: true),
            bench(index: 1, reps: 1, weight: 100, isPR: true),
          ],
        );
        final prs = await service.allPRs();
        expect(prs.where((p) => p.exerciseName == 'Bench').length, 1);
        expect(
          prs.firstWhere((p) => p.exerciseName == 'Bench').oneRepMax,
          closeTo(estimatedOneRepMax(effectiveWeight: 100, reps: 1), 1e-9),
        );
      },
    );

    test(
      'AC-006: recentPRs returns PR sets within the range, newest first',
      () async {
        await db.seedCompletedSession(
          routineId: 'r1',
          routineName: 'A',
          startedAt: DateTime(2026, 6, 10),
          sets: [
            SeedSet(
              exercisePosition: 0,
              exerciseName: 'Squat',
              exerciseId: 'eSquat',
              setIndex: 0,
              type: ExerciseType.strength,
              actualReps: 5,
              actualWeight: 120,
              effectiveWeight: 120,
              estimated1RM: estimatedOneRepMax(effectiveWeight: 120, reps: 5),
              completedAt: DateTime(2026, 6, 10),
              skipped: false,
              isPR: true,
            ),
          ],
        );
        await db.seedCompletedSession(
          routineId: 'r1',
          routineName: 'A',
          startedAt: DateTime(2026, 6, 23),
          sets: [bench(index: 0, reps: 5, weight: 90, isPR: true)],
        );
        final prs = await service.recentPRs(28, asOf: asOf);
        // Bench (Jun 23) is newer than Squat (Jun 10).
        expect(prs.map((p) => p.exerciseName), ['Bench', 'Squat']);
      },
    );

    test(
      'AC-007: bestLifts returns the top lifts by estimated 1RM, limited to the requested count',
      () async {
        await db.seedCompletedSession(
          routineId: 'r1',
          routineName: 'A',
          startedAt: DateTime(2026, 6, 23),
          sets: [
            bench(index: 0, reps: 1, weight: 100, isPR: true), // 1RM 100
            SeedSet(
              exercisePosition: 1,
              exerciseName: 'Squat',
              exerciseId: 'eSquat',
              setIndex: 0,
              type: ExerciseType.strength,
              actualReps: 1,
              actualWeight: 150,
              effectiveWeight: 150,
              estimated1RM: estimatedOneRepMax(effectiveWeight: 150, reps: 1),
              completedAt: asOf,
              skipped: false,
              isPR: true,
            ), // 1RM 150 — the best
            SeedSet(
              exercisePosition: 2,
              exerciseName: 'Row',
              exerciseId: 'eRow',
              setIndex: 0,
              type: ExerciseType.strength,
              actualReps: 1,
              actualWeight: 50,
              effectiveWeight: 50,
              estimated1RM: estimatedOneRepMax(effectiveWeight: 50, reps: 1),
              completedAt: asOf,
              skipped: false,
              isPR: true,
            ), // 1RM 50 — should be truncated away
          ],
        );
        final lifts = await service.bestLifts(limit: 2);
        expect(lifts.length, 2);
        // Ranked by 1RM descending, capped at `limit` — Row (the weakest
        // lift) is truncated away, not just any 2 of the 3.
        expect(lifts.map((l) => l.exerciseName), ['Squat', 'Bench']);
      },
    );

    test(
      'AC-008: planAdherencePercent returns the completed-versus-required percentage for active plans in the range',
      () async {
        // No active plans → no adherence figure.
        expect(await service.planAdherencePercent(28, asOf: asOf), isNull);

        // One active plan, two scheduled entries, one week in range (7 days
        // → ceil(7/7) = 1 week) → required = 2. Only one entry's session
        // completed → adherence = 1/2 * 100 = 50%.
        final routineId = await db.insertRoutine(name: 'Push Day A');
        await db.insertPlanRow(
          PlansCompanion.insert(
            id: 'plan1',
            name: 'PPL',
            status: PlanStatus.active,
            order: 0,
            createdAt: asOf,
          ),
        );
        await db.insertPlanEntryRow(
          PlanEntriesCompanion.insert(
            id: 'entry1',
            planId: 'plan1',
            routineId: routineId,
            dayOfWeek: const Value(0),
            order: 0,
          ),
        );
        await db.insertPlanEntryRow(
          PlanEntriesCompanion.insert(
            id: 'entry2',
            planId: 'plan1',
            routineId: routineId,
            dayOfWeek: const Value(2),
            order: 1,
          ),
        );
        await db.seedCompletedSession(
          routineId: routineId,
          routineName: 'Push Day A',
          planId: 'plan1',
          planEntryId: 'entry1',
          startedAt: asOf,
        );
        expect(
          await service.planAdherencePercent(7, asOf: asOf),
          closeTo(50.0, 1e-9),
        );
      },
    );
  });
}
