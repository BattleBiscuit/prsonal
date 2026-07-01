import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/theme/app_colors.dart';
import 'package:prsonal_app/widgets/pr_row_widget.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('PrRow', () {
    testWidgets(
      'AC-001: Widget renders the exercise name, date, weight and 1RM',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            const PrRow(
              exerciseName: 'Bench Press',
              dateLabel: 'Jun 23',
              weightLabel: '90kg',
              oneRmLabel: '1RM: 95kg',
            ),
          ),
        );
        expect(find.text('Bench Press'), findsOneWidget);
        expect(find.text('Jun 23'), findsOneWidget);
        expect(find.text('90kg'), findsOneWidget);
        expect(find.text('1RM: 95kg'), findsOneWidget);
      },
    );

    testWidgets(
      'AC-002: Widget calls onTap when tapped and onTap is non-null',
      (tester) async {
        var tapped = false;
        await tester.pumpWidget(
          _wrap(
            PrRow(
              exerciseName: 'Bench Press',
              dateLabel: 'Jun 23',
              weightLabel: '90kg',
              oneRmLabel: '1RM: 95kg',
              onTap: () => tapped = true,
            ),
          ),
        );
        await tester.tap(find.byType(PrRow));
        expect(tapped, isTrue);
      },
    );

    testWidgets(
      'Weight and 1RM render mono tabular numerals (design_system.md tenet #3 "Data stability")',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            const PrRow(
              exerciseName: 'Bench Press',
              dateLabel: 'Jun 23',
              weightLabel: '90kg',
              oneRmLabel: '1RM: 95kg',
            ),
          ),
        );
        for (final text in ['90kg', '1RM: 95kg']) {
          final style = tester.widget<Text>(find.text(text)).style!;
          expect(style.fontFamily, 'monospace');
          expect(
            style.fontFeatures,
            contains(const FontFeature.tabularFigures()),
          );
        }
      },
    );

    Color? rowFlashColor(WidgetTester tester) {
      final container = tester
          .widgetList<Container>(find.byType(Container))
          .map((c) => c.decoration)
          .whereType<BoxDecoration>()
          .map((d) => d.color)
          .firstWhere((c) => c != null, orElse: () => null);
      return container;
    }

    testWidgets(
      'AC-003: When celebrate is true, the row plays a one-shot accent background '
      'flash that decays to transparent',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            const PrRow(
              exerciseName: 'Bench Press',
              dateLabel: 'Jun 23',
              weightLabel: '90kg',
              oneRmLabel: '1RM: 95kg',
              celebrate: true,
            ),
          ),
        );
        await tester.pump();
        final flashColor = rowFlashColor(tester);
        expect(flashColor, isNotNull);
        expect(flashColor!.a, greaterThan(0));

        await tester.pumpAndSettle();
        final settledColor = rowFlashColor(tester);
        expect(settledColor == null || settledColor.a == 0, isTrue);
      },
    );

    testWidgets(
      'AC-004: When celebrate is false (the default), the row renders with no '
      'background flash',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            const PrRow(
              exerciseName: 'Bench Press',
              dateLabel: 'Jun 23',
              weightLabel: '90kg',
              oneRmLabel: '1RM: 95kg',
            ),
          ),
        );
        await tester.pump();
        final flashColor = rowFlashColor(tester);
        expect(flashColor == null || flashColor.a == 0, isTrue);
      },
    );
  });
}
