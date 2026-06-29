import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/widgets/stat_card_widget.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('StatCard', () {
    testWidgets('AC-001: Widget renders the value and label', (tester) async {
      await tester.pumpWidget(_wrap(const StatCard(value: '12', label: 'WORKOUTS')));
      expect(find.text('12'), findsOneWidget);
      expect(find.text('WORKOUTS'), findsOneWidget);
    });

    testWidgets('AC-002: Widget renders a leading icon when provided', (tester) async {
      await tester.pumpWidget(
          _wrap(const StatCard(value: '3', label: 'BEST STREAK', icon: Icons.local_fire_department)));
      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    });

    testWidgets('AC-003: Widget defaults to the neutral tone', (tester) async {
      await tester.pumpWidget(_wrap(const StatCard(value: '12', label: 'WORKOUTS')));
      final card = tester.widget<StatCard>(find.byType(StatCard));
      expect(card.tone, StatTone.neutral);
    });

    testWidgets('AC-004: Widget renders flat — no enclosing card chrome (no bordered/filled box)',
        (tester) async {
      await tester.pumpWidget(_wrap(const StatCard(value: '12', label: 'WORKOUTS')));
      expect(
        find.byWidgetPredicate((w) =>
            w is Container &&
            w.decoration is BoxDecoration &&
            (w.decoration as BoxDecoration).border != null),
        findsNothing,
      );
    });
  });
}
