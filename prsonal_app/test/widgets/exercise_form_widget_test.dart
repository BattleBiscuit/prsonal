import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/models/exercise.dart';
import 'package:prsonal_app/widgets/exercise_form_widget.dart';
import 'package:prsonal_app/widgets/exercise_search_input_widget.dart';

const _options = [
  ExerciseOption(id: 'e1', name: 'Bench Press', type: ExerciseType.strength, primaryMuscles: [Muscle.chest]),
];

ExerciseFormData _benchInitial() => const ExerciseFormData(
      exerciseId: 'e1',
      exerciseName: 'Bench Press',
      type: ExerciseType.strength,
      sets: [],
    );

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('ExerciseForm', () {
    testWidgets('AC-001: Widget renders an exercise picker and at least one set row',
        (tester) async {
      await tester.pumpWidget(_wrap(ExerciseForm(
        exercises: _options,
        onSubmit: (_) {},
        onCancel: () {},
      )));
      expect(find.byType(ExerciseSearchInput), findsOneWidget);
      expect(find.text('Add set'), findsOneWidget);
    });

    testWidgets('AC-002: Adding a set appends a new set row', (tester) async {
      await tester.pumpWidget(_wrap(ExerciseForm(
        initial: _benchInitial(),
        exercises: _options,
        onSubmit: (_) {},
        onCancel: () {},
      )));
      final before = find.bySemanticsLabel('Remove set').evaluate().length;
      await tester.tap(find.text('Add set'));
      await tester.pumpAndSettle();
      final after = find.bySemanticsLabel('Remove set').evaluate().length;
      expect(after, before + 1);
    });

    testWidgets('AC-003: Removing a set removes it; the remove control is disabled when only one set remains',
        (tester) async {
      await tester.pumpWidget(_wrap(ExerciseForm(
        initial: _benchInitial(),
        exercises: _options,
        onSubmit: (_) {},
        onCancel: () {},
      )));
      await tester.tap(find.text('Add set'));
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Remove set').evaluate().length, 2);
      await tester.tap(find.bySemanticsLabel('Remove set').first);
      await tester.pumpAndSettle();
      // Only one set remains and its remove control is now disabled (inert).
      var removed = true;
      await tester.tap(find.bySemanticsLabel('Remove set').first, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Remove set'), findsOneWidget);
      expect(removed, isTrue);
    });

    testWidgets('AC-004: Toggling bodyweight on a strength set marks that set as bodyweight',
        (tester) async {
      ExerciseFormData? submitted;
      await tester.pumpWidget(_wrap(ExerciseForm(
        initial: _benchInitial(),
        exercises: _options,
        onSubmit: (d) => submitted = d,
        onCancel: () {},
      )));
      await tester.tap(find.text('BW').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(submitted!.sets.first.isBodyweight, isTrue);
    });

    testWidgets('AC-005: Submitting with no exercise selected shows a validation error and does not call onSubmit',
        (tester) async {
      var submitted = false;
      await tester.pumpWidget(_wrap(ExerciseForm(
        exercises: _options,
        onSubmit: (_) => submitted = true,
        onCancel: () {},
      )));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Select an exercise'), findsOneWidget);
      expect(submitted, isFalse);
    });

    testWidgets('AC-006: Submitting a valid form calls onSubmit with the configured sets',
        (tester) async {
      ExerciseFormData? submitted;
      await tester.pumpWidget(_wrap(ExerciseForm(
        initial: _benchInitial(),
        exercises: _options,
        onSubmit: (d) => submitted = d,
        onCancel: () {},
      )));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(submitted, isNotNull);
      expect(submitted!.sets, isNotEmpty);
    });
  });
}
