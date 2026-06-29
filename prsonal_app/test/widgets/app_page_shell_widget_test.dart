import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/widgets/app_page_shell_widget.dart';

Widget _wrap(Widget child) => MaterialApp(home: child);

void main() {
  group('AppPageShell', () {
    testWidgets('AC-001: Widget renders the PRsonal brand wordmark', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const AppPageShell(child: Text('body'))));
      expect(find.bySemanticsLabel('PRsonal'), findsOneWidget);
    });

    testWidgets('AC-002: Widget renders the header content when provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const AppPageShell(header: Text('Progress'), child: Text('body')),
        ),
      );
      expect(find.text('Progress'), findsOneWidget);
    });

    testWidgets(
      'AC-003: Widget shows the workout-in-progress banner with the routine name when showWorkoutBanner is true',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            const AppPageShell(
              showWorkoutBanner: true,
              workoutRoutineName: 'Push Day',
              child: Text('body'),
            ),
          ),
        );
        expect(find.text('Workout in progress'), findsOneWidget);
        expect(find.text('Push Day'), findsOneWidget);
      },
    );

    testWidgets(
      'AC-004: Widget hides the workout-in-progress banner when showWorkoutBanner is false',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            const AppPageShell(showWorkoutBanner: false, child: Text('body')),
          ),
        );
        expect(find.text('Workout in progress'), findsNothing);
      },
    );

    testWidgets(
      'AC-005: Widget calls onResumeWorkout when the banner is tapped',
      (tester) async {
        var resumed = false;
        await tester.pumpWidget(
          _wrap(
            AppPageShell(
              showWorkoutBanner: true,
              workoutRoutineName: 'Push Day',
              onResumeWorkout: () => resumed = true,
              child: const Text('body'),
            ),
          ),
        );
        await tester.tap(find.text('Workout in progress'));
        expect(resumed, isTrue);
      },
    );

    testWidgets('AC-006: Widget renders its body child', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppPageShell(child: Text('hello body'))),
      );
      expect(find.text('hello body'), findsOneWidget);
    });
  });
}
