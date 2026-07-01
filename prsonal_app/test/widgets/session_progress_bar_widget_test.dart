import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/widgets/session_progress_bar_widget.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('SessionProgressBar', () {
    testWidgets(
      'AC-001: Widget renders a fill whose width factor equals progress',
      (tester) async {
        await tester.pumpWidget(_wrap(const SessionProgressBar(progress: 0.5)));
        await tester.pumpAndSettle();
        final box = tester.widget<FractionallySizedBox>(
          find.byType(FractionallySizedBox),
        );
        expect(box.widthFactor, 0.5);
      },
    );

    testWidgets(
      'AC-002: Widget clamps progress below 0 to 0 and above 1 to 1',
      (tester) async {
        await tester.pumpWidget(_wrap(const SessionProgressBar(progress: 1.5)));
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<FractionallySizedBox>(find.byType(FractionallySizedBox))
              .widthFactor,
          1.0,
        );
        await tester.pumpWidget(
          _wrap(const SessionProgressBar(progress: -0.5)),
        );
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<FractionallySizedBox>(find.byType(FractionallySizedBox))
              .widthFactor,
          0.0,
        );
      },
    );

    testWidgets(
      'AC-003: A progress change animates the fill\'s width over AppDurations.slow (400ms) '
      'instead of snapping instantly',
      (tester) async {
        await tester.pumpWidget(_wrap(const SessionProgressBar(progress: 0.0)));
        await tester.pumpAndSettle();

        await tester.pumpWidget(_wrap(const SessionProgressBar(progress: 1.0)));
        // Immediately after the change (before the 400ms animation completes)
        // the fill must not yet be at its final width.
        await tester.pump();
        final midway = tester
            .widget<FractionallySizedBox>(find.byType(FractionallySizedBox))
            .widthFactor!;
        expect(midway, lessThan(1.0));

        await tester.pumpAndSettle();
        expect(
          tester
              .widget<FractionallySizedBox>(find.byType(FractionallySizedBox))
              .widthFactor,
          1.0,
        );
      },
    );
  });
}
