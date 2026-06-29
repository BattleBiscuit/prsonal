import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/models/exercise.dart';
import 'package:prsonal_app/services/session_service.dart' show ActiveSetStatus;
import 'package:prsonal_app/widgets/set_row_widget.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('SetRow', () {
    testWidgets(
      'AC-001: An upcoming set renders its set number and planned target',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            const SetRow(
              index: 2,
              kind: ExerciseType.strength,
              status: ActiveSetStatus.upcoming,
              plannedLabel: '8×82.5kg',
            ),
          ),
        );
        expect(find.text('3'), findsOneWidget); // index + 1
        expect(find.text('8×82.5kg'), findsOneWidget);
      },
    );

    testWidgets(
      'AC-002: The active set renders editable primary and secondary inputs and a complete checkbox',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            SetRow(
              index: 0,
              kind: ExerciseType.strength,
              status: ActiveSetStatus.active,
              plannedLabel: '8×82.5kg',
              onToggleComplete: () {},
            ),
          ),
        );
        expect(find.byType(TextField), findsNWidgets(2));
        expect(find.bySemanticsLabel('Complete set'), findsOneWidget);
      },
    );

    testWidgets(
      'AC-003: A completed set renders its logged values in a checked state',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            const SetRow(
              index: 0,
              kind: ExerciseType.strength,
              status: ActiveSetStatus.completed,
              plannedLabel: '8×80kg',
              actualLabel: '8×82.5kg',
            ),
          ),
        );
        expect(find.text('8×82.5kg'), findsOneWidget);
      },
    );

    testWidgets(
      'AC-004: A completed set that set a personal record renders a PR indicator',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            const SetRow(
              index: 0,
              kind: ExerciseType.strength,
              status: ActiveSetStatus.completed,
              plannedLabel: '8×80kg',
              actualLabel: '8×90kg',
              isPR: true,
            ),
          ),
        );
        expect(find.bySemanticsLabel('Personal record'), findsOneWidget);
      },
    );

    testWidgets('AC-005: A skipped set renders a skipped treatment', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const SetRow(
            index: 0,
            kind: ExerciseType.strength,
            status: ActiveSetStatus.skipped,
            plannedLabel: '8×80kg',
          ),
        ),
      );
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets(
      'AC-006: Tapping the active set\'s checkbox invokes onToggleComplete',
      (tester) async {
        var toggled = false;
        await tester.pumpWidget(
          _wrap(
            SetRow(
              index: 0,
              kind: ExerciseType.strength,
              status: ActiveSetStatus.active,
              plannedLabel: '8×82.5kg',
              onToggleComplete: () => toggled = true,
            ),
          ),
        );
        await tester.tap(find.bySemanticsLabel('Complete set'));
        expect(toggled, isTrue);
      },
    );

    testWidgets(
      'AC-007: The active set\'s inputs display the provided primaryValue and secondaryValue and preserve typed input across rebuilds',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            SetRow(
              index: 0,
              kind: ExerciseType.strength,
              status: ActiveSetStatus.active,
              plannedLabel: '8×82.5kg',
              primaryValue: '8',
              secondaryValue: '82.5',
              onPrimaryChanged: (_) {},
              onSecondaryChanged: (_) {},
              onToggleComplete: () {},
            ),
          ),
        );
        // Both seeded values are visible in the inputs.
        expect(find.text('8'), findsOneWidget);
        expect(find.text('82.5'), findsOneWidget);

        // Typing into the primary field is reflected, and a rebuild with the
        // same widget config preserves it (no controller reset on every build).
        await tester.enterText(find.byType(TextField).first, '9');
        await tester.pump();
        expect(find.text('9'), findsOneWidget);
      },
    );
  });
}
