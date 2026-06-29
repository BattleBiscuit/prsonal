import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/widgets/exercise_list_item_widget.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('ExerciseListItem', () {
    testWidgets('AC-001: Widget renders the exercise name and sets summary', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          ExerciseListItem(
            name: 'Bench Press',
            setsSummary: '3 sets · 10×80kg',
            onTap: () {},
            onDelete: () {},
          ),
        ),
      );
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('3 sets · 10×80kg'), findsOneWidget);
    });

    testWidgets('AC-002: Widget renders a drag handle', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ExerciseListItem(
            name: 'Bench Press',
            setsSummary: '3 sets',
            onTap: () {},
            onDelete: () {},
          ),
        ),
      );
      expect(find.bySemanticsLabel('Reorder exercise'), findsOneWidget);
    });

    testWidgets('AC-003: Widget calls onTap when the body is tapped', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          ExerciseListItem(
            name: 'Bench Press',
            setsSummary: '3 sets',
            onTap: () => tapped = true,
            onDelete: () {},
          ),
        ),
      );
      await tester.tap(find.text('Bench Press'));
      expect(tapped, isTrue);
    });

    testWidgets(
      'AC-004: Widget calls onDelete when the delete button is tapped',
      (tester) async {
        var deleted = false;
        await tester.pumpWidget(
          _wrap(
            ExerciseListItem(
              name: 'Bench Press',
              setsSummary: '3 sets',
              onTap: () {},
              onDelete: () => deleted = true,
            ),
          ),
        );
        await tester.tap(find.bySemanticsLabel('Remove exercise'));
        expect(deleted, isTrue);
      },
    );
  });
}
