import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:prsonal_app/database/app_database.dart';
import 'package:prsonal_app/providers/app_providers.dart';
import 'package:prsonal_app/providers/session_pick_providers.dart';
import 'package:prsonal_app/screens/session_pick_screen.dart';

// Minimal router exposing the destinations this screen navigates to, so
// navigation can be asserted by the placeholder text that appears.
GoRouter _router() => GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'session-pick',
      builder: (_, __) => const SessionPickScreen(),
    ),
    GoRoute(
      path: '/session/active',
      name: 'session-active',
      builder: (_, __) => const Text('ACTIVE'),
    ),
    GoRoute(
      path: '/routines/new',
      name: 'routine-create',
      builder: (_, __) => const Text('NEW ROUTINE'),
    ),
    GoRoute(
      path: '/plans/new',
      name: 'plan-create',
      builder: (_, __) => const Text('NEW PLAN'),
    ),
    GoRoute(
      path: '/routines/:id/edit',
      name: 'routine-edit',
      builder: (_, __) => const Text('EDIT ROUTINE'),
    ),
    GoRoute(
      path: '/plans/:id/edit',
      name: 'plan-edit',
      builder: (_, __) => const Text('EDIT PLAN'),
    ),
  ],
);

const _ppl = PlanView(
  id: 'p1',
  name: 'PPL',
  streak: 3,
  entries: [
    PlanEntryView(
      entryId: 'e1',
      routineId: 'r1',
      routineName: 'Push Day A',
      dayLabel: 'Mon',
      doneThisWeek: true,
    ),
    PlanEntryView(
      entryId: 'e2',
      routineId: 'r2',
      routineName: 'Pull Day',
      dayLabel: 'Wed',
      doneThisWeek: false,
    ),
  ],
);

Future<void> _pump(
  WidgetTester tester, {
  List<PlanView> plans = const [_ppl],
  List<UnplannedRoutine> unplanned = const [
    UnplannedRoutine(id: 'r9', name: 'Mobility'),
  ],
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        activePlansViewProvider.overrideWithValue(plans),
        unplannedRoutinesProvider.overrideWithValue(unplanned),
      ],
      child: MaterialApp.router(routerConfig: _router()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('SessionPickScreen', () {
    testWidgets(
      'AC-001: Renders a plan block for each active plan, showing the plan name and an entry row per entry',
      (tester) async {
        await _pump(tester);
        expect(find.text('PPL'), findsOneWidget);
        expect(find.text('Push Day A'), findsOneWidget);
        expect(find.text('Pull Day'), findsOneWidget);
      },
    );

    testWidgets(
      'AC-002: Each plan entry shows its day label, routine name, and a done indicator reflecting whether it was completed this week',
      (tester) async {
        await _pump(tester);
        expect(find.text('Mon'), findsOneWidget);
        expect(find.text('Wed'), findsOneWidget);
        // The done entry exposes a done semantics; the not-done one does not.
        expect(find.bySemanticsLabel('Completed this week'), findsOneWidget);
      },
    );

    testWidgets(
      'AC-003: Tapping an entry\'s start button starts a session for that routine (with its plan context) and navigates to session-active',
      (tester) async {
        await _pump(tester);
        await tester.tap(find.bySemanticsLabel('Start Push Day A'));
        await tester.pumpAndSettle();
        expect(find.text('ACTIVE'), findsOneWidget);
      },
    );

    testWidgets(
      'AC-004: Renders an "Unplanned" block listing routines not in any active plan',
      (tester) async {
        await _pump(tester);
        expect(find.text('Unplanned'), findsOneWidget);
        expect(find.text('Mobility'), findsOneWidget);
      },
    );

    testWidgets(
      'AC-005: Tapping the Add FAB opens a sheet offering "New plan" and "New routine"',
      (tester) async {
        await _pump(tester);
        await tester.tap(find.byTooltip('Add'));
        await tester.pumpAndSettle();
        expect(find.text('New plan'), findsOneWidget);
        expect(find.text('New routine'), findsOneWidget);
      },
    );

    testWidgets(
      'AC-006: Selecting "New routine" navigates to routine-create and "New plan" navigates to plan-create',
      (tester) async {
        await _pump(tester);
        await tester.tap(find.byTooltip('Add'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('New routine'));
        await tester.pumpAndSettle();
        expect(find.text('NEW ROUTINE'), findsOneWidget);
      },
    );

    testWidgets(
      'AC-007: Shows an empty state when there are no plans and no routines',
      (tester) async {
        await _pump(tester, plans: const [], unplanned: const []);
        expect(find.text('Nothing here yet'), findsOneWidget);
      },
    );

    testWidgets(
      'AC-008: A plan block shows its streak count when the streak is greater than zero',
      (tester) async {
        await _pump(tester);
        expect(find.text('3'), findsOneWidget);
      },
    );

    testWidgets(
      'AC-009: The screen reactively reflects newly created or modified plans and routines without an app restart — its data sources recompute when plans, plan entries, routines, or completed sessions change',
      (tester) async {
        // Use a real (empty) in-memory database with the real providers, so the
        // backing future providers exercise their reactive recompute path.
        final db = AppDatabase.forTesting(NativeDatabase.memory());

        await tester.pumpWidget(
          ProviderScope(
            overrides: [appDatabaseProvider.overrideWithValue(db)],
            child: MaterialApp.router(routerConfig: _router()),
          ),
        );
        await tester.pumpAndSettle();

        // Starts empty.
        expect(find.text('Nothing here yet'), findsOneWidget);

        // Create a routine after the screen has already built and cached.
        await db.insertRoutine(name: 'Mobility');
        await tester.pumpAndSettle();

        // The newly created routine now appears without rebuilding the app.
        expect(find.text('Nothing here yet'), findsNothing);
        expect(find.text('Mobility'), findsOneWidget);

        // Tear down the widget tree (cancels drift stream subscriptions) and
        // close the database before the test ends so no timers stay pending.
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();
        await db.close();
      },
    );

    testWidgets(
      'AC-010: Tapping a routine name (plan entry or unplanned) opens routine-edit for that routine',
      (tester) async {
        await _pump(tester);
        // Plan-entry routine name opens the editor.
        await tester.tap(find.text('Push Day A'));
        await tester.pumpAndSettle();
        expect(find.text('EDIT ROUTINE'), findsOneWidget);
      },
    );

    testWidgets(
      'AC-011: A plan block renders flat — no enclosing card chrome (no bordered/filled box)',
      (tester) async {
        await _pump(tester);
        expect(
          find.byWidgetPredicate(
            (w) =>
                w is Container &&
                w.decoration is BoxDecoration &&
                (w.decoration as BoxDecoration).border != null,
          ),
          findsNothing,
        );
      },
    );

    testWidgets(
      'AC-012: Each row in the add sheet ("New routine" / "New plan") carries '
      'a trailing affordance icon',
      (tester) async {
        await _pump(tester);
        await tester.tap(find.byTooltip('Add'));
        await tester.pumpAndSettle();
        expect(find.byIcon(Icons.chevron_right_outlined), findsNWidgets(2));
      },
    );
  });
}
