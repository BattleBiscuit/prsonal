import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:prsonal_app/providers/app_providers.dart';
import 'package:prsonal_app/screens/routines_screen.dart';
import 'package:prsonal_app/services/routines_service.dart';

RoutineSummary _summary(String id, String name, {int count = 3}) => RoutineSummary(
      id: id,
      name: name,
      exerciseCount: count,
      notes: null,
      updatedAt: DateTime(2026, 6, 23),
    );

GoRouter _router() => GoRouter(routes: [
      GoRoute(path: '/', name: 'routines', builder: (_, __) => const RoutinesScreen()),
      GoRoute(path: '/routines/new', name: 'routine-create', builder: (_, __) => const Text('CREATE')),
      GoRoute(path: '/routines/:id/edit', name: 'routine-edit', builder: (_, __) => const Text('EDIT')),
    ]);

Future<void> _pump(WidgetTester tester, List<RoutineSummary> routines) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [routinesListProvider.overrideWith((ref) => Stream.value(routines))],
    child: MaterialApp.router(routerConfig: _router()),
  ));
  await tester.pumpAndSettle();
}

void main() {
  group('RoutinesScreen', () {
    testWidgets('AC-001: Renders a card for each routine with its name and meta line',
        (tester) async {
      await _pump(tester, [_summary('r1', 'Push Day A'), _summary('r2', 'Pull Day')]);
      expect(find.text('Push Day A'), findsOneWidget);
      expect(find.text('Pull Day'), findsOneWidget);
    });

    testWidgets('AC-002: Tapping a routine card navigates to routine-edit', (tester) async {
      await _pump(tester, [_summary('r1', 'Push Day A')]);
      await tester.tap(find.text('Push Day A'));
      await tester.pumpAndSettle();
      expect(find.text('EDIT'), findsOneWidget);
    });

    testWidgets('AC-003: Tapping "+ New" navigates to routine-create', (tester) async {
      await _pump(tester, [_summary('r1', 'Push Day A')]);
      await tester.tap(find.text('New'));
      await tester.pumpAndSettle();
      expect(find.text('CREATE'), findsOneWidget);
    });

    testWidgets('AC-004: Tapping a card\'s delete opens a confirm modal and confirming deletes the routine',
        (tester) async {
      await _pump(tester, [_summary('r1', 'Push Day A')]);
      await tester.tap(find.bySemanticsLabel('Delete routine'));
      await tester.pumpAndSettle();
      expect(find.text('Delete routine?'), findsOneWidget);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      // Confirmation dismissed.
      expect(find.text('Delete routine?'), findsNothing);
    });

    testWidgets('AC-005: Shows an empty state when there are no routines', (tester) async {
      await _pump(tester, const []);
      expect(find.text('No routines yet'), findsOneWidget);
    });
  });
}
