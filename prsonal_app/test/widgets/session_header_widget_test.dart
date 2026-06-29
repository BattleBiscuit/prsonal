import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
  });
}
