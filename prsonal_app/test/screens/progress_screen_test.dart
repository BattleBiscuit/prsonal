import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:prsonal_app/providers/progress_providers.dart';
import 'package:prsonal_app/screens/progress_screen.dart';
import 'package:prsonal_app/services/history_service.dart';
import 'package:prsonal_app/services/progress_service.dart';
import 'package:prsonal_app/widgets/chart_slider_widget.dart';
import 'package:prsonal_app/widgets/pr_row_widget.dart';

PRItem _pr(String name) => PRItem(
  exerciseName: name,
  oneRepMax: 95,
  reps: 5,
  weight: 90,
  isBodyweight: false,
  date: DateTime(2026, 6, 23),
);

GoRouter _router() => GoRouter(
  routes: [
    GoRoute(
      path: '/',
      name: 'progress',
      builder: (_, __) => const ProgressScreen(),
    ),
    GoRoute(
      path: '/progress/prs',
      name: 'all-prs',
      builder: (_, __) => const Text('ALL PRS'),
    ),
    GoRoute(
      path: '/progress/history',
      name: 'history',
      builder: (_, __) => const Text('HISTORY'),
    ),
    GoRoute(
      path: '/progress/history/:id',
      name: 'history-detail',
      builder: (_, __) => const Text('DETAIL'),
    ),
  ],
);

Future<void> _pump(WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        progressSummaryProvider.overrideWith(
          (ref) async => const ProgressSummary(
            workoutCount: 12,
            volumeTrendPercent: 8,
            adherencePercent: 87,
            bestStreak: 3,
            muscleBalance: {},
            sessionVolumes: [],
          ),
        ),
        recentPrsProvider.overrideWith((ref) async => [_pr('Bench Press')]),
        historyPreviewProvider.overrideWith(
          (ref) async => [
            SessionSummary(
              id: 's1',
              routineName: 'Push Day A',
              startedAt: DateTime(2026, 6, 23),
              durationLabel: '47m',
              volume: 4230,
              abandoned: false,
            ),
          ],
        ),
      ],
      child: MaterialApp.router(routerConfig: _router()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('ProgressScreen', () {
    testWidgets(
      'AC-001: Renders the workout-count, volume-trend, plan-adherence and best-streak metric cards',
      (tester) async {
        await _pump(tester);
        expect(find.text('12'), findsOneWidget);
        expect(find.textContaining('8%'), findsOneWidget);
        expect(find.textContaining('87%'), findsOneWidget);
        expect(find.text('3'), findsOneWidget);
      },
    );

    testWidgets(
      'AC-002: Changing the range toggle reloads the metrics for that range',
      (tester) async {
        await _pump(tester);
        await tester.tap(find.text('8w'));
        await tester.pumpAndSettle();
        expect(find.text('8w'), findsOneWidget);
      },
    );

    testWidgets(
      'AC-003: Renders a chart slider containing the muscle-balance and volume charts',
      (tester) async {
        await _pump(tester);
        expect(find.byType(ChartSlider), findsOneWidget);
      },
    );

    testWidgets('AC-004: Renders recent PRs, each as a PR row', (tester) async {
      await _pump(tester);
      expect(find.byType(PrRow), findsWidgets);
    });

    testWidgets('AC-005: "View all PRs" navigates to all-prs', (tester) async {
      await _pump(tester);
      await tester.tap(find.byTooltip('View all PRs'));
      await tester.pumpAndSettle();
      expect(find.text('ALL PRS'), findsOneWidget);
    });

    testWidgets('AC-006: A history preview row navigates to history-detail', (
      tester,
    ) async {
      await _pump(tester);
      await tester.ensureVisible(find.text('Push Day A'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Push Day A'));
      await tester.pumpAndSettle();
      expect(find.text('DETAIL'), findsOneWidget);
    });

    testWidgets('AC-007: "View all history" navigates to history', (
      tester,
    ) async {
      await _pump(tester);
      await tester.ensureVisible(find.byTooltip('View all history'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('View all history'));
      await tester.pumpAndSettle();
      expect(find.text('HISTORY'), findsOneWidget);
    });

    testWidgets(
      'AC-008: A history preview row carries a trailing affordance icon',
      (tester) async {
        await _pump(tester);
        final row = find.ancestor(
          of: find.text('Push Day A'),
          matching: find.byType(ListTile),
        );
        expect(
          find.descendant(
            of: row,
            matching: find.byIcon(Icons.chevron_right_outlined),
          ),
          findsOneWidget,
        );
      },
    );
  });
}
