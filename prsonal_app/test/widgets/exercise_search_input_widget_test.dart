import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/models/exercise.dart';
import 'package:prsonal_app/widgets/exercise_search_input_widget.dart';

const _options = [
  ExerciseOption(
    id: 'e1',
    name: 'Bench Press',
    type: ExerciseType.strength,
    primaryMuscles: [Muscle.chest],
  ),
  ExerciseOption(
    id: 'e2',
    name: 'Squat',
    type: ExerciseType.strength,
    primaryMuscles: [Muscle.legs],
  ),
];

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('ExerciseSearchInput', () {
    testWidgets(
      'AC-001: Widget renders the selected exercise name, or a placeholder when none is selected',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            ExerciseSearchInput(
              exercises: _options,
              onSelected: (_) {},
              selectedName: 'Bench Press',
            ),
          ),
        );
        expect(find.text('Bench Press'), findsOneWidget);

        await tester.pumpWidget(
          _wrap(ExerciseSearchInput(exercises: _options, onSelected: (_) {})),
        );
        expect(find.text('Select exercise'), findsOneWidget);
      },
    );

    testWidgets(
      'AC-002: Tapping the field opens a search sheet listing the exercises',
      (tester) async {
        await tester.pumpWidget(
          _wrap(ExerciseSearchInput(exercises: _options, onSelected: (_) {})),
        );
        await tester.tap(find.text('Select exercise'));
        await tester.pumpAndSettle();
        expect(find.text('Bench Press'), findsOneWidget);
        expect(find.text('Squat'), findsOneWidget);
      },
    );

    testWidgets('AC-003: Typing in the search filters the listed exercises', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(ExerciseSearchInput(exercises: _options, onSelected: (_) {})),
      );
      await tester.tap(find.text('Select exercise'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'squ');
      await tester.pumpAndSettle();
      expect(find.text('Squat'), findsOneWidget);
      expect(find.text('Bench Press'), findsNothing);
    });

    testWidgets(
      'AC-004: Selecting an exercise calls onSelected and closes the sheet',
      (tester) async {
        ExerciseOption? chosen;
        await tester.pumpWidget(
          _wrap(
            ExerciseSearchInput(
              exercises: _options,
              onSelected: (o) => chosen = o,
            ),
          ),
        );
        await tester.tap(find.text('Select exercise'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Squat'));
        await tester.pumpAndSettle();
        expect(chosen?.id, 'e2');
        // Sheet closed: the search field is gone.
        expect(find.byType(TextField), findsNothing);
      },
    );

    testWidgets(
      'AC-005: When the query matches no exercise a "Create" option is shown and calls onCreate with the query',
      (tester) async {
        String? created;
        await tester.pumpWidget(
          _wrap(
            ExerciseSearchInput(
              exercises: _options,
              onSelected: (_) {},
              onCreate: (q) => created = q,
            ),
          ),
        );
        await tester.tap(find.text('Select exercise'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), 'Deadlift');
        await tester.pumpAndSettle();
        expect(find.text('Create "Deadlift"'), findsOneWidget);
        await tester.tap(find.text('Create "Deadlift"'));
        await tester.pumpAndSettle();
        expect(created, 'Deadlift');
      },
    );
  });
}
