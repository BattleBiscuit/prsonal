import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/widgets/routine_card_widget.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('RoutineCard', () {
    testWidgets('AC-001: Widget renders the routine name and meta line', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          RoutineCard(
            name: 'Push Day A',
            metaLine: '3 exercises · Updated 2h ago',
            onTap: () {},
            onDelete: () {},
          ),
        ),
      );
      expect(find.text('Push Day A'), findsOneWidget);
      expect(find.text('3 exercises · Updated 2h ago'), findsOneWidget);
    });

    testWidgets(
      'AC-002: Widget renders the notes preview when provided and omits it when null',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            RoutineCard(
              name: 'Push Day A',
              metaLine: '3 exercises',
              notes: 'Heavy day',
              onTap: () {},
              onDelete: () {},
            ),
          ),
        );
        expect(find.text('Heavy day'), findsOneWidget);

        await tester.pumpWidget(
          _wrap(
            RoutineCard(
              name: 'Push Day A',
              metaLine: '3 exercises',
              onTap: () {},
              onDelete: () {},
            ),
          ),
        );
        expect(find.text('Heavy day'), findsNothing);
      },
    );

    testWidgets('AC-003: Widget calls onTap when the card body is tapped', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          RoutineCard(
            name: 'Push Day A',
            metaLine: '3 exercises',
            onTap: () => tapped = true,
            onDelete: () {},
          ),
        ),
      );
      await tester.tap(find.text('Push Day A'));
      expect(tapped, isTrue);
    });

    testWidgets(
      'AC-004: Widget calls onDelete when the delete button is tapped',
      (tester) async {
        var deleted = false;
        await tester.pumpWidget(
          _wrap(
            RoutineCard(
              name: 'Push Day A',
              metaLine: '3 exercises',
              onTap: () {},
              onDelete: () => deleted = true,
            ),
          ),
        );
        await tester.tap(find.bySemanticsLabel('Delete routine'));
        expect(deleted, isTrue);
      },
    );

    testWidgets(
      'AC-005: Widget renders flat — no enclosing card chrome (no bordered/filled box)',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            RoutineCard(
              name: 'Push Day A',
              metaLine: '3 exercises',
              onTap: () {},
              onDelete: () {},
            ),
          ),
        );
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
  });
}
