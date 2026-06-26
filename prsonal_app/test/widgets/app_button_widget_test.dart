import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/widgets/app_button_widget.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('AppButton', () {
    testWidgets('AC-001: Widget renders the label', (tester) async {
      await tester.pumpWidget(_wrap(AppButton(label: 'Save', onPressed: () {})));
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('AC-002: Widget calls onPressed when tapped and onPressed is non-null',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(AppButton(label: 'Save', onPressed: () => tapped = true)),
      );
      await tester.tap(find.byType(AppButton));
      expect(tapped, isTrue);
    });

    testWidgets('AC-003: Widget does not call onPressed and renders at reduced opacity when onPressed is null',
        (tester) async {
      await tester.pumpWidget(_wrap(const AppButton(label: 'Save', onPressed: null)));
      await tester.tap(find.byType(AppButton), warnIfMissed: false);
      final opacity = tester.widget<Opacity>(
        find.descendant(
            of: find.byType(AppButton), matching: find.byType(Opacity)),
      );
      expect(opacity.opacity, 0.4);
    });

    testWidgets('AC-004: Widget renders a leading icon before the label when an icon is provided',
        (tester) async {
      await tester.pumpWidget(
        _wrap(AppButton(
          label: 'Save',
          icon: const Icon(Icons.check),
          onPressed: () {},
        )),
      );
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });
}
