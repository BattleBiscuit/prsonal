import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/database/app_database.dart';
import 'package:prsonal_app/models/exercise.dart';
import 'package:prsonal_app/models/workout_math.dart';
import 'package:prsonal_app/providers/app_providers.dart';
import 'package:prsonal_app/services/library_service.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late LibraryService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)]);
    service = container.read(libraryServiceProvider);
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  group('LibraryService', () {
    test('AC-001: createExercise inserts an exercise and returns its id', () async {
      final id = await service.createExercise(
          name: 'Bench Press',
          type: ExerciseType.strength,
          primaryMuscles: const [Muscle.chest],
          secondaryMuscles: const []);
      expect(id, isNotEmpty);
    });

    test('AC-002: watchExercises emits exercises ordered alphabetically by name', () async {
      await service.createExercise(
          name: 'Squat', type: ExerciseType.strength, primaryMuscles: const [], secondaryMuscles: const []);
      await service.createExercise(
          name: 'Bench', type: ExerciseType.strength, primaryMuscles: const [], secondaryMuscles: const []);
      final list = await service.watchExercises().first;
      expect(list.map((e) => e.name), ['Bench', 'Squat']);
    });

    test('AC-003: updateExercise changes the exercise fields', () async {
      final id = await service.createExercise(
          name: 'Bench', type: ExerciseType.strength, primaryMuscles: const [], secondaryMuscles: const []);
      await service.updateExercise(id, name: 'Incline Bench');
      final list = await service.watchExercises().first;
      expect(list.single.name, 'Incline Bench');
    });

    test('AC-004: deleteExercise removes the exercise', () async {
      final id = await service.createExercise(
          name: 'Bench', type: ExerciseType.strength, primaryMuscles: const [], secondaryMuscles: const []);
      await service.deleteExercise(id);
      expect(await service.watchExercises().first, isEmpty);
    });

    test('AC-005: watchExercises includes the best estimated 1RM for each exercise that has logged PR sets',
        () async {
      final id = await service.createExercise(
          name: 'Bench', type: ExerciseType.strength, primaryMuscles: const [], secondaryMuscles: const []);
      await db.seedCompletedSession(routineId: 'r1', routineName: 'A', startedAt: DateTime(2026, 6, 23), sets: [
        SeedSet(
          exercisePosition: 0,
          exerciseName: 'Bench',
          exerciseId: id,
          setIndex: 0,
          type: ExerciseType.strength,
          actualReps: 1,
          actualWeight: 100,
          effectiveWeight: 100,
          estimated1RM: estimatedOneRepMax(effectiveWeight: 100, reps: 1),
          completedAt: DateTime(2026, 6, 23),
          skipped: false,
          isPR: true,
        ),
      ]);
      final list = await service.watchExercises().first;
      expect(list.single.bestOneRepMax, closeTo(100, 1e-9));
    });

    test('AC-006: searchExercises filters by case-insensitive name substring', () async {
      await service.createExercise(
          name: 'Bench Press', type: ExerciseType.strength, primaryMuscles: const [], secondaryMuscles: const []);
      await service.createExercise(
          name: 'Squat', type: ExerciseType.strength, primaryMuscles: const [], secondaryMuscles: const []);
      final results = await service.searchExercises('bench');
      expect(results.map((e) => e.name), ['Bench Press']);
    });
  });
}
