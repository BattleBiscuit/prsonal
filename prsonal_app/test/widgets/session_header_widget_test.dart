import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/theme/app_colors.dart';
import 'package:prsonal_app/widgets/live_dot_widget.dart';
import 'package:prsonal_app/widgets/session_header_widget.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('SessionHeader', () {
    testWidgets('AC-001: Widget renders the routine name', (tester) async {
      await tester.pumpWidget(
        _wrap(
          SessionHeader(
            routineName: 'Push Day A',
            elapsed: const Duration(minutes: 12, seconds: 31),
            onQuit: () {},
            onFinish: () {},
          ),
        ),
      );
      expect(find.text('Push Day A'), findsOneWidget);
    });

    testWidgets(
      'AC-002: Widget renders the elapsed time formatted as M:SS under an hour',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            SessionHeader(
              routineName: 'Push Day A',
              elapsed: const Duration(minutes: 12, seconds: 31),
              onQuit: () {},
              onFinish: () {},
            ),
          ),
        );
        expect(find.text('12:31'), findsOneWidget);
      },
    );

    testWidgets(
      'Elapsed time renders in text-3 mono tabular numerals (design_system.md '
      'tenet #3 "Data stability"; specs/widgets/session_header.md:27)',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            SessionHeader(
              routineName: 'Push Day A',
              elapsed: const Duration(minutes: 12, seconds: 31),
              onQuit: () {},
              onFinish: () {},
            ),
          ),
        );
        final elapsed = tester.widget<Text>(find.text('12:31'));
        expect(elapsed.style!.fontFamily, 'monospace');
        expect(
          elapsed.style!.fontFeatures,
          contains(FontFeature.tabularFigures()),
        );
        expect(elapsed.style!.color, AppColors.dark.text3);
      },
    );

    testWidgets('AC-003: Widget calls onQuit when the quit action is tapped', (
      tester,
    ) async {
      var quit = false;
      await tester.pumpWidget(
        _wrap(
          SessionHeader(
            routineName: 'Push Day A',
            elapsed: Duration.zero,
            onQuit: () => quit = true,
            onFinish: () {},
          ),
        ),
      );
      await tester.tap(find.bySemanticsLabel('Quit workout'));
      expect(quit, isTrue);
    });

    testWidgets(
      'AC-004: Widget calls onFinish when the finish action is tapped',
      (tester) async {
        var finished = false;
        await tester.pumpWidget(
          _wrap(
            SessionHeader(
              routineName: 'Push Day A',
              elapsed: Duration.zero,
              onQuit: () {},
              onFinish: () => finished = true,
            ),
          ),
        );
        await tester.tap(find.bySemanticsLabel('Finish workout'));
        expect(finished, isTrue);
      },
    );

    testWidgets(
      'AC-005: Widget renders a LiveDot next to the elapsed time (the session heartbeat)',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            SessionHeader(
              routineName: 'Push Day A',
              elapsed: const Duration(minutes: 12, seconds: 31),
              onQuit: () {},
              onFinish: () {},
            ),
          ),
        );
        expect(find.byType(LiveDot), findsOneWidget);
      },
    );
  });
}
