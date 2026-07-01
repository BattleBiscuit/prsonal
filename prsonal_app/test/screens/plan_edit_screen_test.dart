import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prsonal_app/providers/app_providers.dart';
import 'package:prsonal_app/screens/plan_edit_screen.dart';
import 'package:prsonal_app/services/plans_service.dart';
import 'package:prsonal_app/services/routines_service.dart';
import 'package:prsonal_app/widgets/day_of_week_selector_widget.dart';

class _MockPlansService extends Mock implements PlansService {}

RoutineSummary _routine(String id, String name) => RoutineSummary(
  id: id,
  name: name,
  exerciseCount: 3,
  notes: null,
  updatedAt: DateTime(2026, 6, 1),
);

PlanDraft _draft() => PlanDraft(
  id: 'p1',
  name: 'PPL',
  entries: [
    PlanEntryDraft(
      id: 'e1',
      routineId: 'r1',
      routineName: 'Push Day A',
      dayOfWeek: 0,
    ),
  ],
);

GoRouter _router(Widget screen) => GoRouter(
  routes: [
    GoRoute(path: '/', name: 'plans', builder: (_, __) => screen),
    GoRoute(
      path: '/pick',
      name: 'session-pick',
      builder: (_, __) => const Text('BACK'),
    ),
  ],
);

Future<_MockPlansService> _pump(
  WidgetTester tester, {
  String? planId,
  PlanDraft? draft,
}) async {
  final service = _MockPlansService();
  when(() => service.createPlan(any())).thenAnswer((_) async => 'p-new');
  when(() => service.replaceEntries(any(), any())).thenAnswer((_) async {});
  when(() => service.deletePlan(any())).thenAnswer((_) async {});
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        plansServiceProvider.overrideWithValue(service),
        routinesListProvider.overrideWith(
          (ref) => Stream.value([_routine('r1', 'Push Day A')]),
        ),
        if (planId != null)
          planDraftProvider(planId).overrideWith((ref) async => draft),
      ],
      child: MaterialApp.router(
        routerConfig: _router(PlanEditScreen(planId: planId)),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return service;
}

void main() {
  group('PlanEditScreen', () {
    testWidgets(
      'AC-001: In create mode the name field is empty; in edit mode it is populated from the plan',
      (tester) async {
        await _pump(tester);
        expect(find.text('PPL'), findsNothing);
        await _pump(tester, planId: 'p1', draft: _draft());
        expect(find.text('PPL'), findsOneWidget);
      },
    );

    testWidgets(
      'AC-002: Tapping "Add" opens a routine picker and selecting a routine adds an entry',
      (tester) async {
        await _pump(tester);
        await tester.tap(find.byTooltip('Add entry'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Push Day A'));
        await tester.pumpAndSettle();
        expect(find.byType(DayOfWeekSelector), findsOneWidget);
      },
    );

    testWidgets(
      'AC-003: Each entry exposes a day selector to assign its day of the week',
      (tester) async {
        await _pump(tester, planId: 'p1', draft: _draft());
        expect(find.byType(DayOfWeekSelector), findsOneWidget);
      },
    );

    testWidgets('AC-004: Removing an entry removes it from the list', (
      tester,
    ) async {
      await _pump(tester, planId: 'p1', draft: _draft());
      expect(find.byType(DayOfWeekSelector), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Remove entry'));
      await tester.pumpAndSettle();
      expect(find.byType(DayOfWeekSelector), findsNothing);
    });

    testWidgets(
      'AC-005: Tapping Save persists the plan name and entries and navigates back',
      (tester) async {
        final service = await _pump(tester);
        await tester.enterText(find.byType(TextField).first, 'New Plan');
        await tester.tap(find.byTooltip('Save'));
        await tester.pumpAndSettle();
        verify(() => service.createPlan('New Plan')).called(1);
      },
    );

    testWidgets(
      'AC-006: Saving with an empty name shows a validation error and does not persist',
      (tester) async {
        final service = await _pump(tester);
        await tester.tap(find.byTooltip('Save'));
        await tester.pumpAndSettle();
        expect(find.text('Plan name is required'), findsOneWidget);
        verifyNever(() => service.createPlan(any()));
      },
    );

    testWidgets(
      'AC-007: In edit mode, deleting the plan removes it and navigates back',
      (tester) async {
        final service = await _pump(tester, planId: 'p1', draft: _draft());
        await tester.tap(find.text('Delete plan'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();
        verify(() => service.deletePlan('p1')).called(1);
      },
    );
  });
}
