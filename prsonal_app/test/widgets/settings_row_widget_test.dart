import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/widgets/settings_row_widget.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('SettingsRow', () {
    testWidgets('AC-001: Widget renders the title and subtitle', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsRow(
        title: 'Export backup',
        subtitle: 'Choose what to include',
      )));
      expect(find.text('Export backup'), findsOneWidget);
      expect(find.text('Choose what to include'), findsOneWidget);
    });

    testWidgets('AC-002: Widget renders a trailing widget when provided', (tester) async {
      await tester.pumpWidget(_wrap(const SettingsRow(
        title: 'Export backup',
        trailing: Icon(Icons.upload),
      )));
      expect(find.byIcon(Icons.upload), findsOneWidget);
    });

    testWidgets('AC-003: Widget calls onTap when tapped and onTap is non-null', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(SettingsRow(
        title: 'Export backup',
        onTap: () => tapped = true,
      )));
      await tester.tap(find.text('Export backup'));
      expect(tapped, isTrue);
    });
  });
}
