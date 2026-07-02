import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/database/app_database.dart';
import 'package:prsonal_app/models/exercise.dart';
import 'package:prsonal_app/models/routine_exercise.dart';
import 'package:prsonal_app/providers/app_providers.dart';
import 'package:prsonal_app/services/routines_service.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late RoutinesService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    service = container.read(routinesServiceProvider);
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<String> seedExercise(String name) =>
      db.insertExercise(name: name, type: ExerciseType.strength);

  group('RoutinesService', () {
    test(
      'AC-001: createRoutine inserts a routine and returns its id',
      () async {
        final id = await service.createRoutine(name: 'Push Day A');
        expect(id, isNotEmpty);
        final draft = await service.getRoutineForEdit(id);
        expect(draft.name, 'Push Day A');
      },
    );

    test(
      'AC-002: watchRoutines emits routines ordered most-recently-updated first, each with its exercise count',
      () async {
        final a = await service.createRoutine(name: 'A');
        final b = await service.createRoutine(name: 'B');
        final ex = await seedExercise('Bench');
        await service.addExercise(
          b,
          exerciseId: ex,
          sets: [SetTarget.strength()],
        );
        final list = await service.watchRoutines().first;
        expect(list.first.id, b); // b updated most recently
        expect(list.firstWhere((r) => r.id == b).exerciseCount, 1);
        expect(list.firstWhere((r) => r.id == a).exerciseCount, 0);
      },
    );

    test(
      'AC-003: updateRoutine changes the fields and refreshes updatedAt',
      () async {
        final id = await service.createRoutine(name: 'A');
        final before = (await service.getRoutineForEdit(id)).updatedAt;
        await service.updateRoutine(id, name: 'A2');
        final after = await service.getRoutineForEdit(id);
        expect(after.name, 'A2');
        // Strict: updateRoutine guarantees advancement even when called
        // within the same clock tick (it bumps by 1s rather than reusing
        // `existing.updatedAt`), so this must never be merely "not before".
        expect(after.updatedAt.isAfter(before), isTrue);
      },
    );

    test(
      'AC-004: deleteRoutine removes the routine and all of its exercises',
      () async {
        final id = await service.createRoutine(name: 'A');
        final ex = await seedExercise('Bench');
        await service.addExercise(
          id,
          exerciseId: ex,
          sets: [SetTarget.strength()],
        );
        await service.deleteRoutine(id);
        expect(
          () => service.getRoutineForEdit(id),
          throwsA(isA<NotFoundException>()),
        );
        // The cascade, not just the parent lookup — an orphaned-row
        // regression would still pass the assertion above.
        expect(await db.routineExercisesForRoutine(id), isEmpty);
      },
    );

    test(
      'AC-005: addExercise appends an exercise at the next position with its planned sets',
      () async {
        final id = await service.createRoutine(name: 'A');
        final ex = await seedExercise('Bench');
        await service.addExercise(
          id,
          exerciseId: ex,
          sets: [SetTarget.strength(), SetTarget.strength()],
        );
        final draft = await service.getRoutineForEdit(id);
        expect(draft.exercises.single.position, 0);
        expect(draft.exercises.single.sets.length, 2);
      },
    );

    test(
      'AC-006: removeExercise deletes the exercise and renumbers the remaining positions to be contiguous',
      () async {
        final id = await service.createRoutine(name: 'A');
        final e1 = await seedExercise('Bench');
        final e2 = await seedExercise('Squat');
        final e3 = await seedExercise('Row');
        for (final e in [e1, e2, e3]) {
          await service.addExercise(
            id,
            exerciseId: e,
            sets: [SetTarget.strength()],
          );
        }
        final middle = (await service.getRoutineForEdit(id)).exercises[1].id;
        await service.removeExercise(middle);
        final positions = (await service.getRoutineForEdit(
          id,
        )).exercises.map((e) => e.position).toList();
        expect(positions, [0, 1]);
      },
    );

    test('AC-007: reorderExercises persists the new positions', () async {
      final id = await service.createRoutine(name: 'A');
      final e1 = await seedExercise('Bench');
      final e2 = await seedExercise('Squat');
      await service.addExercise(
        id,
        exerciseId: e1,
        sets: [SetTarget.strength()],
      );
      await service.addExercise(
        id,
        exerciseId: e2,
        sets: [SetTarget.strength()],
      );
      final ids = (await service.getRoutineForEdit(
        id,
      )).exercises.map((e) => e.id).toList();
      await service.reorderExercises(id, [ids[1], ids[0]]);
      final reordered = (await service.getRoutineForEdit(
        id,
      )).exercises.map((e) => e.id).toList();
      expect(reordered, [ids[1], ids[0]]);
    });

    test(
      'AC-008: getRoutineForEdit returns the routine with its exercises resolved by library name in position order',
      () async {
        final id = await service.createRoutine(name: 'A');
        final ex = await seedExercise('Bench Press');
        await service.addExercise(
          id,
          exerciseId: ex,
          sets: [SetTarget.strength()],
        );
        final draft = await service.getRoutineForEdit(id);
        expect(draft.exercises.single.exerciseName, 'Bench Press');
      },
    );
  });
}
