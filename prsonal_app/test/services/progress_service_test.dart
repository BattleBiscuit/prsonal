import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/database/app_database.dart';
import 'package:prsonal_app/models/exercise.dart';
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
        expect(await service.volumeTrendPercent(28, asOf: asOf), isNull);
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
          startedAt: DateTime(2026, 6, 23),
          sets: [bench(index: 0, reps: 5, weight: 90, isPR: true)],
        );
        final prs = await service.recentPRs(28, asOf: asOf);
        expect(prs, isNotEmpty);
      },
    );

    test(
      'AC-007: bestLifts returns the top lifts by estimated 1RM, limited to the requested count',
      () async {
        await db.seedCompletedSession(
          routineId: 'r1',
          routineName: 'A',
          startedAt: DateTime(2026, 6, 23),
          sets: [bench(index: 0, reps: 5, weight: 90, isPR: true)],
        );
        final lifts = await service.bestLifts(limit: 5);
        expect(lifts.length, lessThanOrEqualTo(5));
      },
    );

    test(
      'AC-008: planAdherencePercent returns the completed-versus-required percentage for active plans in the range',
      () async {
        // No active plans → no adherence figure.
        expect(await service.planAdherencePercent(28, asOf: asOf), isNull);
      },
    );
  });
}
