import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/models/exercise.dart';
import 'package:prsonal_app/widgets/library_exercise_form_widget.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('LibraryExerciseForm', () {
    testWidgets('AC-001: Widget renders a name field and a strength/cardio type toggle',
        (tester) async {
      await tester.pumpWidget(_wrap(LibraryExerciseForm(onSubmit: (_) {}, onCancel: () {})));
      expect(find.byType(TextField), findsWidgets);
      expect(find.text('Strength'), findsOneWidget);
      expect(find.text('Cardio'), findsOneWidget);
    });

    testWidgets('AC-002: Widget renders selectable primary and secondary muscle chips',
        (tester) async {
      await tester.pumpWidget(_wrap(LibraryExerciseForm(onSubmit: (_) {}, onCancel: () {})));
      // The seven muscles appear as chips (at least under Primary).
      expect(find.text('Chest'), findsWidgets);
      expect(find.text('Glutes'), findsWidgets);
    });

    testWidgets('AC-003: Submitting with an empty name shows a validation error and does not call onSubmit',
        (tester) async {
      var submitted = false;
      await tester.pumpWidget(
          _wrap(LibraryExerciseForm(onSubmit: (_) => submitted = true, onCancel: () {})));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Name is required'), findsOneWidget);
      expect(submitted, isFalse);
    });

    testWidgets('AC-004: Submitting a valid form calls onSubmit with the selected type and muscles',
        (tester) async {
      LibraryExerciseData? data;
      await tester.pumpWidget(
          _wrap(LibraryExerciseForm(onSubmit: (d) => data = d, onCancel: () {})));
      await tester.enterText(find.byType(TextField).first, 'Bench Press');
      await tester.tap(find.text('Chest').first);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(data, isNotNull);
      expect(data!.name, 'Bench Press');
      expect(data!.primaryMuscles, contains(Muscle.chest));
    });
  });
}
