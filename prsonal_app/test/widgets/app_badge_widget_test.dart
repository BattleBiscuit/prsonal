import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/widgets/app_badge_widget.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('AppBadge', () {
    testWidgets('AC-001: Widget renders the label text', (tester) async {
      await tester.pumpWidget(_wrap(const AppBadge(label: 'strength')));
      expect(find.text('strength'), findsOneWidget);
    });

    testWidgets('AC-002: Widget defaults to the neutral variant when no variant is provided',
        (tester) async {
      await tester.pumpWidget(_wrap(const AppBadge(label: 'strength')));
      final badge = tester.widget<AppBadge>(find.byType(AppBadge));
      expect(badge.variant, AppBadgeVariant.neutral);
    });
  });
}
