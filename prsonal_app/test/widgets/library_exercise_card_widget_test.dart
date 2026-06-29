import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/models/exercise.dart';
import 'package:prsonal_app/widgets/library_exercise_card_widget.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('LibraryExerciseCard', () {
    testWidgets('AC-001: Widget renders the name and a type badge', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          LibraryExerciseCard(
            name: 'Bench Press',
            type: ExerciseType.strength,
            musclesLabel: 'Chest, Shoulders',
            onTap: () {},
            onDelete: () {},
          ),
        ),
      );
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('strength'), findsOneWidget);
    });

    testWidgets('AC-002: Widget renders the primary muscles label', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          LibraryExerciseCard(
            name: 'Bench Press',
            type: ExerciseType.strength,
            musclesLabel: 'Chest, Shoulders',
            onTap: () {},
            onDelete: () {},
          ),
        ),
      );
      expect(find.text('Chest, Shoulders'), findsOneWidget);
    });

    testWidgets(
      'AC-003: Widget renders a PR chip when prLabel is provided and omits it when null',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            LibraryExerciseCard(
              name: 'Bench Press',
              type: ExerciseType.strength,
              musclesLabel: 'Chest',
              prLabel: '🏆 95kg',
              onTap: () {},
              onDelete: () {},
            ),
          ),
        );
        expect(find.text('🏆 95kg'), findsOneWidget);

        await tester.pumpWidget(
          _wrap(
            LibraryExerciseCard(
              name: 'Bench Press',
              type: ExerciseType.strength,
              musclesLabel: 'Chest',
              onTap: () {},
              onDelete: () {},
            ),
          ),
        );
        expect(find.text('🏆 95kg'), findsNothing);
      },
    );

    testWidgets('AC-004: Widget calls onTap when the card body is tapped', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          LibraryExerciseCard(
            name: 'Bench Press',
            type: ExerciseType.strength,
            musclesLabel: 'Chest',
            onTap: () => tapped = true,
            onDelete: () {},
          ),
        ),
      );
      await tester.tap(find.text('Bench Press'));
      expect(tapped, isTrue);
    });

    testWidgets(
      'AC-005: Widget calls onDelete when the delete button is tapped',
      (tester) async {
        var deleted = false;
        await tester.pumpWidget(
          _wrap(
            LibraryExerciseCard(
              name: 'Bench Press',
              type: ExerciseType.strength,
              musclesLabel: 'Chest',
              onTap: () {},
              onDelete: () => deleted = true,
            ),
          ),
        );
        await tester.tap(find.bySemanticsLabel('Delete exercise'));
        expect(deleted, isTrue);
      },
    );

    testWidgets(
      'AC-006: Widget renders flat — no enclosing card chrome (the row itself has no bordered/filled box)',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            LibraryExerciseCard(
              name: 'Bench Press',
              type: ExerciseType.strength,
              musclesLabel: 'Chest',
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
