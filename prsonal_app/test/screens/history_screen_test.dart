import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prsonal_app/providers/app_providers.dart';
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

Future<_MockHistoryService> _pump(
  WidgetTester tester,
  List<SessionSummary> page,
) async {
  final service = _MockHistoryService();
  when(() => service.count()).thenAnswer((_) async => page.length);
  when(
    () => service.loadPage(
      page: any(named: 'page'),
      pageSize: any(named: 'pageSize'),
    ),
  ).thenAnswer((_) async => page);
  when(() => service.deleteSession(any())).thenAnswer((_) async {});
  await tester.pumpWidget(
    ProviderScope(
      overrides: [historyServiceProvider.overrideWithValue(service)],
      child: MaterialApp.router(routerConfig: _router()),
    ),
  );
  await tester.pumpAndSettle();
  return service;
}

void main() {
  group('HistoryScreen', () {
    testWidgets(
      'AC-001: Lists completed sessions grouped by month, newest first',
      (tester) async {
        await _pump(tester, [
          _summary('s1', DateTime(2026, 6, 23)),
          _summary('s2', DateTime(2026, 5, 10)),
        ]);
        expect(find.textContaining('June 2026'), findsOneWidget);
        expect(find.textContaining('May 2026'), findsOneWidget);
      },
    );

    testWidgets(
      'AC-002: Each card shows the routine name, date, duration and volume',
      (tester) async {
        await _pump(tester, [_summary('s1', DateTime(2026, 6, 23))]);
        expect(find.text('Push Day A'), findsOneWidget);
        expect(find.textContaining('47m'), findsOneWidget);
      },
    );

    testWidgets('AC-003: An abandoned session is labelled as abandoned', (
      tester,
    ) async {
      await _pump(tester, [
        _summary('s1', DateTime(2026, 6, 23), abandoned: true),
      ]);
      expect(find.textContaining('Abandoned'), findsOneWidget);
    });

    testWidgets('AC-004: Tapping a card navigates to history-detail', (
      tester,
    ) async {
      await _pump(tester, [_summary('s1', DateTime(2026, 6, 23))]);
      await tester.tap(find.text('Push Day A'));
      await tester.pumpAndSettle();
      expect(find.text('DETAIL'), findsOneWidget);
    });

    testWidgets(
      'AC-005: Tapping delete confirms and then removes the session',
      (tester) async {
        final service = await _pump(tester, [
          _summary('s1', DateTime(2026, 6, 23)),
        ]);
        await tester.tap(find.bySemanticsLabel('Delete workout'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();
        verify(() => service.deleteSession('s1')).called(1);
      },
    );

    testWidgets('AC-006: Scrolling to the bottom loads the next page', (
      tester,
    ) async {
      final service = await _pump(tester, [
        for (var i = 0; i < 20; i++)
          _summary('s$i', DateTime(2026, 6, 23 - (i % 20))),
      ]);
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -4000));
      await tester.pumpAndSettle();
      verify(
        () => service.loadPage(page: 2, pageSize: any(named: 'pageSize')),
      ).called(1);
    });

    testWidgets('AC-007: Shows an empty state when there is no history', (
      tester,
    ) async {
      await _pump(tester, const []);
      expect(find.text('No workouts yet'), findsOneWidget);
    });
  });
}
