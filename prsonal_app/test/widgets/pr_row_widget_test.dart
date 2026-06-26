import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/widgets/pr_row_widget.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('PrRow', () {
    testWidgets('AC-001: Widget renders the exercise name, date, weight and 1RM', (tester) async {
      await tester.pumpWidget(_wrap(const PrRow(
        exerciseName: 'Bench Press',
        dateLabel: 'Jun 23',
        weightLabel: '90kg',
        oneRmLabel: '1RM: 95kg',
      )));
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Jun 23'), findsOneWidget);
      expect(find.text('90kg'), findsOneWidget);
      expect(find.text('1RM: 95kg'), findsOneWidget);
    });

    testWidgets('AC-002: Widget calls onTap when tapped and onTap is non-null', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(PrRow(
        exerciseName: 'Bench Press',
        dateLabel: 'Jun 23',
        weightLabel: '90kg',
        oneRmLabel: '1RM: 95kg',
        onTap: () => tapped = true,
      )));
      await tester.tap(find.byType(PrRow));
      expect(tapped, isTrue);
    });
  });
}
