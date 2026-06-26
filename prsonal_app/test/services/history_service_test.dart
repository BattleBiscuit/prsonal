import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/database/app_database.dart';
import 'package:prsonal_app/models/exercise.dart';
import 'package:prsonal_app/models/workout_math.dart';
import 'package:prsonal_app/providers/app_providers.dart';
import 'package:prsonal_app/services/history_service.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late HistoryService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)]);
    service = container.read(historyServiceProvider);
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<String> seedSession({
    required DateTime startedAt,
    List<SeedSet> sets = const [],
  }) =>
      db.seedCompletedSession(
        routineId: 'r1',
        routineName: 'Push Day A',
        startedAt: startedAt,
        completedAt: startedAt.add(const Duration(minutes: 47)),
        sets: sets,
      );

  SeedSet strengthSet({
    required int index,
    required String name,
    required int reps,
    required double weight,
    bool isPR = false,
    bool skipped = false,
  }) =>
      SeedSet(
        exercisePosition: 0,
        exerciseName: name,
        setIndex: index,
        type: ExerciseType.strength,
        actualReps: skipped ? null : reps,
        actualWeight: skipped ? null : weight,
        effectiveWeight: skipped ? null : weight,
        estimated1RM: skipped ? null : estimatedOneRepMax(effectiveWeight: weight, reps: reps),
        completedAt: skipped ? null : startedNow,
        skipped: skipped,
        isPR: isPR,
      );

  group('HistoryService', () {
    test('AC-001: count returns the number of completed sessions', () async {
      await seedSession(startedAt: DateTime(2026, 6, 23));
      await seedSession(startedAt: DateTime(2026, 6, 20));
      expect(await service.count(), 2);
    });

    test('AC-002: loadPage returns completed sessions newest first, paged by pageSize',
        () async {
      await seedSession(startedAt: DateTime(2026, 6, 20));
      await seedSession(startedAt: DateTime(2026, 6, 23));
      final page = await service.loadPage(page: 1, pageSize: 1);
      expect(page.length, 1);
      expect(page.first.startedAt, DateTime(2026, 6, 23));
    });

    test('AC-003: getDetail returns the session with its sets grouped by exercise in position order',
        () async {
      final id = await seedSession(startedAt: DateTime(2026, 6, 23), sets: [
        strengthSet(index: 0, name: 'Bench', reps: 8, weight: 80),
        strengthSet(index: 1, name: 'Bench', reps: 8, weight: 80),
      ]);
      final detail = await service.getDetail(id);
      expect(detail.exercises.single.name, 'Bench');
      expect(detail.exercises.single.sets.length, 2);
    });

    test('AC-004: getDetail reports the names of exercises that set a personal record in the session',
        () async {
      final id = await seedSession(startedAt: DateTime(2026, 6, 23), sets: [
        strengthSet(index: 0, name: 'Bench', reps: 8, weight: 90, isPR: true),
      ]);
      final detail = await service.getDetail(id);
      expect(detail.prNames, contains('Bench'));
    });

    test('AC-005: deleteSession removes the session and all of its sets', () async {
      final id = await seedSession(startedAt: DateTime(2026, 6, 23), sets: [
        strengthSet(index: 0, name: 'Bench', reps: 8, weight: 80),
      ]);
      await service.deleteSession(id);
      expect(() => service.getDetail(id), throwsA(isA<NotFoundException>()));
    });

    test('AC-006: updateSetActuals persists edited reps and weight and recomputes effectiveWeight and estimated1RM',
        () async {
      final id = await seedSession(startedAt: DateTime(2026, 6, 23), sets: [
        strengthSet(index: 0, name: 'Bench', reps: 8, weight: 80),
      ]);
      final setId = (await service.getDetail(id)).exercises.single.sets.single.id;
      await service.updateSetActuals(setId, reps: 10, weight: 85, isBodyweight: false);
      final updated = (await db.workoutSetsForSession(id)).single;
      expect(updated.actualReps, 10);
      expect(updated.effectiveWeight, 85);
      expect(updated.estimated1RM, closeTo(estimatedOneRepMax(effectiveWeight: 85, reps: 10), 1e-9));
    });

    test('AC-007: a completed session with zero logged volume is reported as abandoned',
        () async {
      final id = await seedSession(startedAt: DateTime(2026, 6, 23), sets: [
        strengthSet(index: 0, name: 'Bench', reps: 0, weight: 0, skipped: true),
      ]);
      final detail = await service.getDetail(id);
      expect(detail.abandoned, isTrue);
    });
  });
}

/// Fixed timestamp used by seed helpers (Date.now is unavailable in this harness).
final startedNow = DateTime(2026, 6, 23, 9, 30);
