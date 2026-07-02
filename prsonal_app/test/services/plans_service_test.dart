import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/database/app_database.dart';
import 'package:prsonal_app/models/exercise.dart';
import 'package:prsonal_app/providers/app_providers.dart';
import 'package:prsonal_app/services/plans_service.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late PlansService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    service = container.read(plansServiceProvider);
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<String> seedRoutine(String name) => db.insertRoutine(name: name);

  group('PlansService', () {
    test(
      'AC-001: createPlan inserts an active plan and returns its id',
      () async {
        final id = await service.createPlan('PPL');
        expect(id, isNotEmpty);
        expect((await service.getPlanForEdit(id)).name, 'PPL');
      },
    );

    test(
      'AC-002: getPlanForEdit returns the plan with its entries, routine names resolved, in order',
      () async {
        final r = await seedRoutine('Push Day A');
        final p = await service.createPlan('PPL');
        await service.replaceEntries(p, [
          PlanEntryInput(routineId: r, dayOfWeek: 0),
        ]);
        final draft = await service.getPlanForEdit(p);
        expect(draft.entries.single.routineName, 'Push Day A');
      },
    );

    test(
      'AC-003: replaceEntries replaces all of a plan\'s entries with the supplied set',
      () async {
        final r1 = await seedRoutine('A');
        final r2 = await seedRoutine('B');
        final p = await service.createPlan('PPL');
        await service.replaceEntries(p, [
          PlanEntryInput(routineId: r1, dayOfWeek: 0),
        ]);
        await service.replaceEntries(p, [
          PlanEntryInput(routineId: r2, dayOfWeek: 1),
          PlanEntryInput(routineId: r2, dayOfWeek: 3),
        ]);
        final draft = await service.getPlanForEdit(p);
        expect(draft.entries.length, 2);
        expect(draft.entries.every((e) => e.routineId == r2), isTrue);
      },
    );

    test(
      'AC-004: deletePlan removes the plan and all of its entries',
      () async {
        final r = await seedRoutine('A');
        final p = await service.createPlan('PPL');
        await service.replaceEntries(p, [
          PlanEntryInput(routineId: r, dayOfWeek: 0),
        ]);
        await service.deletePlan(p);
        expect(
          () => service.getPlanForEdit(p),
          throwsA(isA<NotFoundException>()),
        );
        // The cascade, not just the parent lookup — an orphaned-row
        // regression would still pass the assertion above.
        expect(await db.planEntriesForPlan(p), isEmpty);
      },
    );

    test(
      'AC-005: activePlansView returns only active plans, each with its entries and day labels',
      () async {
        final r = await seedRoutine('Push Day A');
        final active = await service.createPlan('Active');
        await service.replaceEntries(active, [
          PlanEntryInput(routineId: r, dayOfWeek: 0),
        ]);
        final archived = await service.createPlan('Archived');
        await service.updatePlan(archived, status: PlanStatus.archived);

        final view = await service.activePlansView(asOf: DateTime(2026, 6, 24));
        expect(view.map((p) => p.name), ['Active']);
        expect(view.single.entries.single.dayLabel, 'Mon');
      },
    );

    test(
      'AC-006: an entry is marked done-this-week when a completed session references that entry within the asOf week',
      () async {
        final r = await seedRoutine('Push Day A');
        final p = await service.createPlan('PPL');
        await service.replaceEntries(p, [
          PlanEntryInput(routineId: r, dayOfWeek: 0),
        ]);
        final entryId = (await service.getPlanForEdit(p)).entries.single.id;
        await db.seedCompletedSession(
          routineId: r,
          planId: p,
          planEntryId: entryId,
          startedAt: DateTime(2026, 6, 22),
        );

        final view = await service.activePlansView(asOf: DateTime(2026, 6, 24));
        expect(view.single.entries.single.doneThisWeek, isTrue);
      },
    );

    test(
      'AC-007: unplannedRoutines lists only routines not referenced by any active plan',
      () async {
        final inPlan = await seedRoutine('In Plan');
        final loose = await seedRoutine('Loose');
        final p = await service.createPlan('PPL');
        await service.replaceEntries(p, [
          PlanEntryInput(routineId: inPlan, dayOfWeek: 0),
        ]);
        final unplanned = await service.unplannedRoutines();
        expect(unplanned.map((r) => r.name), contains('Loose'));
        expect(unplanned.map((r) => r.name), isNot(contains('In Plan')));
      },
    );

    test(
      'AC-008: streakForPlan counts the consecutive complete weeks ending at the asOf week',
      () async {
        final r = await seedRoutine('Push Day A');
        final p = await service.createPlan('PPL');
        await service.replaceEntries(p, [
          PlanEntryInput(routineId: r, dayOfWeek: 0),
        ]);
        final entryId = (await service.getPlanForEdit(p)).entries.single.id;
        // Current week Monday and previous week Monday completed; week before not.
        await db.seedCompletedSession(
          routineId: r,
          planId: p,
          planEntryId: entryId,
          startedAt: DateTime(2026, 6, 22),
        );
        await db.seedCompletedSession(
          routineId: r,
          planId: p,
          planEntryId: entryId,
          startedAt: DateTime(2026, 6, 15),
        );

        final streak = await service.streakForPlan(
          p,
          asOf: DateTime(2026, 6, 24),
        );
        expect(streak, 2);
      },
    );
  });
}
