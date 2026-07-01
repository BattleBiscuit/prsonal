import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prsonal_app/screens/history_screen.dart';
import 'package:prsonal_app/services/history_service.dart';

class _MockHistoryService extends Mock implements HistoryService {}

SessionSummary _summary(String id, DateTime at, {bool abandoned = false}) =>
    SessionSummary(
      id: id,
      routineName: 'Push Day A',
      startedAt: at,
      durationLabel: '47m',
      volume: abandoned ? 0 : 4230,
      abandoned: abandoned,
    );

GoRouter _router() => GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'history',
      builder: (_, __) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/history/:id',
      name: 'history-detail',
      builder: (_, __) => const Text('DETAIL'),
    ),
  ],
);

/// Pumps HistoryScreen with [service] mocking `watchPage` off of [controller]
/// — a stand-in for the Drift-backed reactive stream. Every call to
/// `watchPage(limit)` (regardless of `limit`) is served from the same
/// broadcast controller so the test can push emissions to simulate the DB
/// reacting to writes.
Future<void> _pump(
  WidgetTester tester,
  _MockHistoryService service,
  StreamController<List<SessionSummary>> controller,
) async {
  when(() => service.watchPage(any())).thenAnswer((_) => controller.stream);
  when(() => service.deleteSession(any())).thenAnswer((_) async {});
  await tester.pumpWidget(
    ProviderScope(
      overrides: [historyServiceProvider.overrideWithValue(service)],
      child: MaterialApp.router(routerConfig: _router()),
    ),
  );
}

void main() {
  group('HistoryScreen', () {
    testWidgets(
      'AC-001: Lists completed sessions grouped by month, newest first',
      (tester) async {
        final service = _MockHistoryService();
        final controller = StreamController<List<SessionSummary>>.broadcast();
        addTearDown(controller.close);
        await _pump(tester, service, controller);
        controller.add([
          _summary('s1', DateTime(2026, 6, 23)),
          _summary('s2', DateTime(2026, 5, 10)),
        ]);
        await tester.pumpAndSettle();
        expect(find.textContaining('June 2026'), findsOneWidget);
        expect(find.textContaining('May 2026'), findsOneWidget);
      },
    );

    testWidgets(
      'AC-002: Each card shows the routine name, date, duration and volume',
      (tester) async {
        final service = _MockHistoryService();
        final controller = StreamController<List<SessionSummary>>.broadcast();
        addTearDown(controller.close);
        await _pump(tester, service, controller);
        controller.add([_summary('s1', DateTime(2026, 6, 23))]);
        await tester.pumpAndSettle();
        expect(find.text('Push Day A'), findsOneWidget);
        expect(find.textContaining('47m'), findsOneWidget);
      },
    );

    testWidgets('AC-003: An abandoned session is labelled as abandoned', (
      tester,
    ) async {
      final service = _MockHistoryService();
      final controller = StreamController<List<SessionSummary>>.broadcast();
      addTearDown(controller.close);
      await _pump(tester, service, controller);
      controller.add([_summary('s1', DateTime(2026, 6, 23), abandoned: true)]);
      await tester.pumpAndSettle();
      expect(find.textContaining('Abandoned'), findsOneWidget);
    });

    testWidgets('AC-004: Tapping a card navigates to history-detail', (
      tester,
    ) async {
      final service = _MockHistoryService();
      final controller = StreamController<List<SessionSummary>>.broadcast();
      addTearDown(controller.close);
      await _pump(tester, service, controller);
      controller.add([_summary('s1', DateTime(2026, 6, 23))]);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Push Day A'));
      await tester.pumpAndSettle();
      expect(find.text('DETAIL'), findsOneWidget);
    });

    testWidgets(
      'AC-005: Tapping delete confirms and then removes the session',
      (tester) async {
        final service = _MockHistoryService();
        final controller = StreamController<List<SessionSummary>>.broadcast();
        addTearDown(controller.close);
        await _pump(tester, service, controller);
        controller.add([_summary('s1', DateTime(2026, 6, 23))]);
        await tester.pumpAndSettle();
        await tester.tap(find.bySemanticsLabel('Delete workout'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();
        verify(() => service.deleteSession('s1')).called(1);
        // No manual list patch in the screen — the (Drift-backed, here
        // simulated) stream is the only source of truth for what's removed.
        controller.add(const []);
        await tester.pumpAndSettle();
        expect(find.text('Push Day A'), findsNothing);
      },
    );

    testWidgets('AC-006: Scrolling to the bottom loads the next page', (
      tester,
    ) async {
      final service = _MockHistoryService();
      final controller = StreamController<List<SessionSummary>>.broadcast();
      addTearDown(controller.close);
      await _pump(tester, service, controller);
      controller.add([
        for (var i = 0; i < 20; i++)
          _summary('s$i', DateTime(2026, 6, 23 - (i % 20))),
      ]);
      await tester.pumpAndSettle();
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -4000));
      // Not pumpAndSettle: the footer spinner shown while waiting on the
      // bigger page is an indeterminate CircularProgressIndicator, which
      // animates forever and would make pumpAndSettle time out.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      verify(() => service.watchPage(40)).called(1);
    });

    testWidgets('AC-007: Shows an empty state when there is no history', (
      tester,
    ) async {
      final service = _MockHistoryService();
      final controller = StreamController<List<SessionSummary>>.broadcast();
      addTearDown(controller.close);
      await _pump(tester, service, controller);
      controller.add(const []);
      await tester.pumpAndSettle();
      expect(find.text('No workouts yet'), findsOneWidget);
    });
  });
}
