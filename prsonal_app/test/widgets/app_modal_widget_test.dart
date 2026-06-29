import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/widgets/app_modal_widget.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('AppModal', () {
    testWidgets('AC-001: Widget renders the title when provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const AppModal(title: 'Finish workout?', child: Text('body'))),
      );
      expect(find.text('Finish workout?'), findsOneWidget);
    });

    testWidgets('AC-002: Widget renders the body child', (tester) async {
      await tester.pumpWidget(
        _wrap(const AppModal(child: Text('Save this workout to history?'))),
      );
      expect(find.text('Save this workout to history?'), findsOneWidget);
    });

    testWidgets('AC-003: Widget renders the actions when provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const AppModal(
            title: 'Finish workout?',
            child: Text('body'),
            actions: [Text('Save to history'), Text('Keep going')],
          ),
        ),
      );
      expect(find.text('Save to history'), findsOneWidget);
      expect(find.text('Keep going'), findsOneWidget);
    });

    testWidgets(
      'AC-004: Widget calls onClose when the close button is tapped',
      (tester) async {
        var closed = false;
        await tester.pumpWidget(
          _wrap(
            AppModal(
              title: 'Finish workout?',
              onClose: () => closed = true,
              child: const Text('body'),
            ),
          ),
        );
        await tester.tap(find.bySemanticsLabel('Close'));
        expect(closed, isTrue);
      },
    );

    testWidgets('AC-005: Widget omits the header when no title is provided', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const AppModal(child: Text('body'))));
      expect(find.bySemanticsLabel('Close'), findsNothing);
    });
  });
}
