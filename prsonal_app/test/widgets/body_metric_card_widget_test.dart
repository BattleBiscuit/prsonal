import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/widgets/body_metric_card_widget.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('BodyMetricCard', () {
    testWidgets('AC-001: Widget renders the metric label and value', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          BodyMetricCard(
            label: 'Bodyweight',
            valueLabel: '82.5 kg',
            icon: Icons.monitor_weight_outlined,
            onTap: () {},
          ),
        ),
      );
      expect(find.text('Bodyweight'), findsOneWidget);
      expect(find.text('82.5 kg'), findsOneWidget);
    });

    testWidgets('AC-002: Widget renders the date label when provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          BodyMetricCard(
            label: 'Bodyweight',
            valueLabel: '82.5 kg',
            dateLabel: 'Today',
            icon: Icons.monitor_weight_outlined,
            onTap: () {},
          ),
        ),
      );
      expect(find.text('Today'), findsOneWidget);
    });

    testWidgets('AC-003: Widget calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrap(
          BodyMetricCard(
            label: 'Bodyweight',
            valueLabel: '—',
            icon: Icons.monitor_weight_outlined,
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.tap(find.byType(BodyMetricCard));
      expect(tapped, isTrue);
    });

    testWidgets(
      'AC-004: Widget renders flat — no enclosing card chrome (no bordered/filled box)',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            BodyMetricCard(
              label: 'Bodyweight',
              valueLabel: '82.5 kg',
              icon: Icons.monitor_weight_outlined,
              onTap: () {},
            ),
          ),
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
      'valueLabel renders mono tabular numerals (design_system.md tenet #3 "Data stability")',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            BodyMetricCard(
              label: 'Bodyweight',
              valueLabel: '82.5 kg',
              icon: Icons.monitor_weight_outlined,
              onTap: () {},
            ),
          ),
        );
        final value = tester.widget<Text>(find.text('82.5 kg'));
        expect(value.style!.fontFamily, 'monospace');
        expect(
          value.style!.fontFeatures,
          contains(const FontFeature.tabularFigures()),
        );
      },
    );

    testWidgets(
      'AC-005: Widget renders a trailing edit affordance icon marking the tile as interactive',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            BodyMetricCard(
              label: 'Bodyweight',
              valueLabel: '82.5 kg',
              icon: Icons.monitor_weight_outlined,
              onTap: () {},
            ),
          ),
        );
        expect(find.byIcon(Icons.edit_outlined), findsOneWidget);
      },
    );
  });
}
