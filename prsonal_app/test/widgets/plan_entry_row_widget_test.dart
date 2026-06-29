import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/widgets/plan_entry_row_widget.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('PlanEntryRow', () {
    testWidgets('AC-001: Widget renders the day label and routine name', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const PlanEntryRow(dayLabel: 'Mon', routineName: 'Push Day A')),
      );
      expect(find.text('Mon'), findsOneWidget);
      expect(find.text('Push Day A'), findsOneWidget);
    });

    testWidgets(
      'AC-002: Widget renders a "Completed this week" indicator when done is true',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            const PlanEntryRow(
              dayLabel: 'Mon',
              routineName: 'Push Day A',
              done: true,
            ),
          ),
        );
        expect(find.bySemanticsLabel('Completed this week'), findsOneWidget);
      },
    );

    testWidgets(
      'AC-003: Widget calls onStart when the start button is tapped',
      (tester) async {
        var started = false;
        await tester.pumpWidget(
          _wrap(
            PlanEntryRow(
              dayLabel: 'Mon',
              routineName: 'Push Day A',
              onStart: () => started = true,
            ),
          ),
        );
        await tester.tap(find.bySemanticsLabel('Start Push Day A'));
        expect(started, isTrue);
      },
    );

    testWidgets(
      'AC-004: The start button is inert when startDisabled is true',
      (tester) async {
        var started = false;
        await tester.pumpWidget(
          _wrap(
            PlanEntryRow(
              dayLabel: 'Mon',
              routineName: 'Push Day A',
              startDisabled: true,
              onStart: () => started = true,
            ),
          ),
        );
        await tester.tap(
          find.bySemanticsLabel('Start Push Day A'),
          warnIfMissed: false,
        );
        expect(started, isFalse);
      },
    );
  });
}
