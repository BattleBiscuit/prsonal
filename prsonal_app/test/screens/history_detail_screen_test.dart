import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prsonal_app/models/exercise.dart';
import 'package:prsonal_app/providers/app_providers.dart';
import 'package:prsonal_app/screens/history_detail_screen.dart';
import 'package:prsonal_app/services/history_service.dart';
import 'package:prsonal_app/theme/app_colors.dart';
import 'package:prsonal_app/widgets/history_set_table_widget.dart';

class _MockHistoryService extends Mock implements HistoryService {}

SessionDetail _detail() => SessionDetail(
  id: 's1',
  routineName: 'Push Day A',
  startedAt: DateTime(2026, 6, 23, 9, 15),
  durationLabel: '47m',
  volume: 4230,
  abandoned: false,
  prNames: const ['Bench Press'],
  exercises: const [
    DetailExercise(
      name: 'Bench Press',
      sets: [
        SetTableRow(
          setIndex: 0,
          plannedLabel: '8×80kg',
          actualLabel: '8×82.5kg',
          skipped: false,
          isPR: true,
          kind: ExerciseType.strength,
        ),
        SetTableRow(
          setIndex: 1,
          plannedLabel: '8×80kg',
          actualLabel: null,
          skipped: true,
          isPR: false,
          kind: ExerciseType.strength,
        ),
      ],
    ),
  ],
);

Future<_MockHistoryService> _pump(WidgetTester tester) async {
  final service = _MockHistoryService();
  when(() => service.getDetail('s1')).thenAnswer((_) async => _detail());
  when(
    () => service.updateSetActuals(
      any(),
      reps: any(named: 'reps'),
      weight: any(named: 'weight'),
      isBodyweight: any(named: 'isBodyweight'),
      skipped: any(named: 'skipped'),
    ),
  ).thenAnswer((_) async {});
  await tester.pumpWidget(
    ProviderScope(
      overrides: [historyServiceProvider.overrideWithValue(service)],
      child: MaterialApp(home: const HistoryDetailScreen(sessionId: 's1')),
    ),
  );
  await tester.pumpAndSettle();
  return service;
}

void main() {
  group('HistoryDetailScreen', () {
    testWidgets(
      'AC-001: Shows the workout summary (routine, date, duration, volume, status)',
      (tester) async {
        await _pump(tester);
        expect(find.text('Push Day A'), findsWidgets);
        expect(find.text('47m'), findsOneWidget);
        expect(find.text('Completed'), findsOneWidget);
      },
    );

    testWidgets(
      'AC-002: Shows a per-exercise set table of planned and actual values',
      (tester) async {
        await _pump(tester);
        expect(find.byType(HistorySetTable), findsOneWidget);
        expect(find.text('8×82.5kg'), findsOneWidget);
      },
    );

    testWidgets(
      'AC-003: Shows a PR banner listing exercises that set a personal record, '
      'styled as the accent-tinted "live/important" surface (accent@0.06 bg, '
      'accent@0.20 hairline)',
      (tester) async {
        await _pump(tester);
        expect(find.textContaining('PRs this session'), findsOneWidget);
        expect(find.text('Bench Press'), findsWidgets);

        final banner = tester
            .widgetList<Container>(find.byType(Container))
            .map((c) => c.decoration)
            .whereType<BoxDecoration>()
            .where((d) {
              final border = d.border;
              return d.color == AppColors.dark.accent.withValues(alpha: 0.06) &&
                  border is Border &&
                  border.top.color ==
                      AppColors.dark.accent.withValues(alpha: 0.20);
            });
        expect(banner, isNotEmpty);
      },
    );

    testWidgets('AC-004: Tapping Edit makes the actual values editable', (
      tester,
    ) async {
      await _pump(tester);
      await tester.tap(find.byTooltip('Edit'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets(
      'AC-005: Saving edits persists the changes and exits edit mode',
      (tester) async {
        final service = await _pump(tester);
        await tester.tap(find.byTooltip('Edit'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).first, '10');
        await tester.tap(find.byTooltip('Save changes'));
        await tester.pumpAndSettle();
        verify(
          () => service.updateSetActuals(
            any(),
            reps: any(named: 'reps'),
            weight: any(named: 'weight'),
            isBodyweight: any(named: 'isBodyweight'),
            skipped: any(named: 'skipped'),
          ),
        ).called(greaterThan(0));
        expect(find.byTooltip('Edit'), findsOneWidget);
      },
    );

    testWidgets('AC-006: A skipped set is shown distinctly', (tester) async {
      await _pump(tester);
      expect(find.text('Skip'), findsOneWidget);
    });
  });
}
