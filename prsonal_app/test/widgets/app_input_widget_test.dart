import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/widgets/app_input_widget.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('AppInput', () {
    testWidgets('AC-001: Widget renders the label when provided', (tester) async {
      await tester.pumpWidget(_wrap(const AppInput(label: 'Routine name')));
      expect(find.text('Routine name'), findsOneWidget);
    });

    testWidgets('AC-002: Widget renders the placeholder hint when provided',
        (tester) async {
      await tester.pumpWidget(_wrap(const AppInput(placeholder: 'e.g. Push Day')));
      expect(find.text('e.g. Push Day'), findsOneWidget);
    });

    testWidgets('AC-003: Widget calls onChanged with the entered text', (tester) async {
      String? changed;
      await tester.pumpWidget(_wrap(AppInput(onChanged: (v) => changed = v)));
      await tester.enterText(find.byType(TextField), 'Pull Day');
      expect(changed, 'Pull Day');
    });

    testWidgets('AC-004: Widget displays the error text when errorText is provided',
        (tester) async {
      await tester.pumpWidget(_wrap(const AppInput(errorText: 'Name is required')));
      expect(find.text('Name is required'), findsOneWidget);
    });

    testWidgets('AC-005: Widget is non-editable when enabled is false', (tester) async {
      await tester.pumpWidget(_wrap(const AppInput(enabled: false)));
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.enabled, isFalse);
    });
  });
}
