import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/widgets/rest_action_button_widget.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('RestActionButton', () {
    testWidgets('AC-001: When not resting, widget renders the given label', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          RestActionButton(resting: false, label: 'Done', onPressed: () {}),
        ),
      );
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets(
      'AC-002: When resting, widget renders the remaining seconds as "Rest Ns"',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            RestActionButton(
              resting: true,
              remainingSeconds: 45,
              label: 'Done',
              onPressed: () {},
            ),
          ),
        );
        expect(find.text('Rest 45s'), findsOneWidget);
      },
    );

    testWidgets('AC-003: Widget calls onPressed when tapped', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        _wrap(
          RestActionButton(
            resting: false,
            label: 'Done',
            onPressed: () => pressed = true,
          ),
        ),
      );
      await tester.tap(find.byType(RestActionButton));
      expect(pressed, isTrue);
    });
  });
}
