import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/widgets/stat_card_widget.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('StatCard', () {
    testWidgets('AC-001: Widget renders the value and label', (tester) async {
      await tester.pumpWidget(
        _wrap(const StatCard(value: '12', label: 'WORKOUTS')),
      );
      expect(find.text('12'), findsOneWidget);
      expect(find.text('WORKOUTS'), findsOneWidget);
    });

    testWidgets('AC-002: Widget renders a leading icon when provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const StatCard(
            value: '3',
            label: 'BEST STREAK',
            icon: Icons.local_fire_department,
          ),
        ),
      );
      expect(find.byIcon(Icons.local_fire_department), findsOneWidget);
    });

    testWidgets(
      'AC-003: The icon renders in the same accent color regardless of tone '
      '— tone is a no-op, and must stay one, per the monochrome identity',
      (tester) async {
        final colors = <Color>{};
        for (final tone in StatTone.values) {
          await tester.pumpWidget(
            _wrap(
              StatCard(
                value: '12',
                label: 'WORKOUTS',
                icon: Icons.local_fire_department,
                tone: tone,
              ),
            ),
          );
          final icon = tester.widget<Icon>(
            find.byIcon(Icons.local_fire_department),
          );
          colors.add(icon.color!);
        }
        // Every tone produced the exact same color — a regression that wired
        // even one StatTone case to a real hue would grow this set past 1.
        expect(colors, hasLength(1));
      },
    );

    testWidgets(
      'AC-004: Widget renders flat — no enclosing card chrome (no bordered/filled box)',
      (tester) async {
        await tester.pumpWidget(
          _wrap(const StatCard(value: '12', label: 'WORKOUTS')),
        );
        expect(
          find.byWidgetPredicate(
            (w) =>
                w is Container &&
                w.decoration is BoxDecoration &&
                (w.decoration as BoxDecoration).border != null,
          ),
          findsNothing,
        );
      },
    );

    testWidgets(
      'Value renders mono tabular numerals (design_system.md tenet #3 "Data stability")',
      (tester) async {
        await tester.pumpWidget(
          _wrap(const StatCard(value: '12', label: 'WORKOUTS')),
        );
        final value = tester.widget<Text>(find.text('12'));
        expect(value.style!.fontFamily, 'monospace');
        expect(
          value.style!.fontFeatures,
          contains(const FontFeature.tabularFigures()),
        );
      },
    );
  });
}
