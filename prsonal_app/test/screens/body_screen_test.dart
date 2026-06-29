import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prsonal_app/models/body_metric.dart';
import 'package:prsonal_app/providers/app_providers.dart';
import 'package:prsonal_app/screens/body_screen.dart';
import 'package:prsonal_app/services/body_service.dart';
import 'package:prsonal_app/widgets/body_metric_card_widget.dart';

class _MockBodyService extends Mock implements BodyService {}

BodyMetric _m(BodyMetricType t, double v) => BodyMetric(
  id: '${t.name}1',
  type: t,
  value: v,
  loggedAt: DateTime(2026, 6, 23),
);

Future<_MockBodyService> _pump(
  WidgetTester tester, {
  Map<BodyMetricType, BodyMetric?>? latest,
  List<BodyMetric>? weightHistory,
}) async {
  final service = _MockBodyService();
  when(
    () => service.watchLatest(),
  ).thenAnswer((_) => Stream.value(latest ?? const {}));
  when(
    () => service.watchHistory(any(), days: any(named: 'days')),
  ).thenAnswer((_) => Stream.value(const []));
  when(
    () => service.watchHistory(BodyMetricType.weight, days: any(named: 'days')),
  ).thenAnswer((_) => Stream.value(weightHistory ?? const []));
  when(
    () => service.log(any(), any(), at: any(named: 'at')),
  ).thenAnswer((_) async {});
  when(() => service.deleteEntry(any())).thenAnswer((_) async {});
  await tester.pumpWidget(
    ProviderScope(
      overrides: [bodyServiceProvider.overrideWithValue(service)],
      child: const MaterialApp(home: BodyScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return service;
}

void main() {
  group('BodyScreen', () {
    testWidgets(
      'AC-001: Renders a metric card for each of the six body metric types',
      (tester) async {
        await _pump(tester);
        expect(find.byType(BodyMetricCard), findsNWidgets(6));
      },
    );

    testWidgets(
      'AC-002: A metric card shows the latest value or a dash when none has been logged',
      (tester) async {
        await _pump(
          tester,
          latest: {BodyMetricType.weight: _m(BodyMetricType.weight, 82.5)},
        );
        expect(find.textContaining('82.5'), findsOneWidget);
        expect(find.text('—'), findsWidgets);
      },
    );

    testWidgets(
      'AC-003: Tapping a metric card opens a log sheet for that metric',
      (tester) async {
        await _pump(tester);
        await tester.tap(find.byType(BodyMetricCard).first);
        await tester.pumpAndSettle();
        expect(find.textContaining('Log'), findsWidgets);
      },
    );

    testWidgets('AC-004: Submitting the log sheet records a new value', (
      tester,
    ) async {
      final service = await _pump(tester);
      await tester.tap(find.byType(BodyMetricCard).first);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, '83');
      await tester.tap(find.text('Log'));
      await tester.pumpAndSettle();
      verify(() => service.log(any(), 83, at: any(named: 'at'))).called(1);
    });

    testWidgets(
      'AC-005: Renders a history list for metrics that have entries',
      (tester) async {
        await _pump(
          tester,
          latest: {BodyMetricType.weight: _m(BodyMetricType.weight, 82.5)},
          weightHistory: [_m(BodyMetricType.weight, 82.5)],
        );
        expect(find.textContaining('BODYWEIGHT HISTORY'), findsOneWidget);
      },
    );

    testWidgets('AC-006: Deleting a history entry removes it', (tester) async {
      final service = await _pump(
        tester,
        latest: {BodyMetricType.weight: _m(BodyMetricType.weight, 82.5)},
        weightHistory: [_m(BodyMetricType.weight, 82.5)],
      );
      await tester.tap(find.bySemanticsLabel('Delete entry').first);
      await tester.pumpAndSettle();
      verify(() => service.deleteEntry('weight1')).called(1);
    });
  });
}
