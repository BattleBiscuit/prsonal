import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/widgets/app_textarea_widget.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('AppTextarea', () {
    testWidgets('AC-001: Widget renders the label when provided', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const AppTextarea(label: 'Notes')));
      expect(find.text('Notes'), findsOneWidget);
    });

    testWidgets(
      'AC-002: Widget renders the configured number of rows (maxLines equals rows)',
      (tester) async {
        await tester.pumpWidget(_wrap(const AppTextarea(rows: 5)));
        final field = tester.widget<TextField>(find.byType(TextField));
        expect(field.maxLines, 5);
      },
    );

    testWidgets('AC-003: Widget calls onChanged with the entered text', (
      tester,
    ) async {
      String? changed;
      await tester.pumpWidget(
        _wrap(AppTextarea(onChanged: (v) => changed = v)),
      );
      await tester.enterText(find.byType(TextField), 'Felt strong today');
      expect(changed, 'Felt strong today');
    });

    testWidgets('AC-004: Widget is non-editable when enabled is false', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const AppTextarea(enabled: false)));
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.enabled, isFalse);
    });
  });
}
