import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/theme/app_colors.dart';
import 'package:prsonal_app/widgets/volume_chart_widget.dart';

Widget _wrap(Widget child, {bool disableAnimations = false}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: disableAnimations),
    child: Scaffold(body: SizedBox(width: 320, height: 240, child: child)),
  ),
);

void main() {
  group('VolumeChart', () {
    testWidgets('AC-001: Widget renders a bar chart for the provided data', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const VolumeChart(
            data: [
              (label: 'Jun 20', volume: 3200),
              (label: 'Jun 23', volume: 4230),
            ],
          ),
        ),
      );
      expect(find.byType(fl.BarChart), findsOneWidget);
    });

    testWidgets('AC-002: Widget shows an empty state when there is no data', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const VolumeChart(data: [])));
      expect(find.text('No volume yet'), findsOneWidget);
    });

    testWidgets(
      'Axis labels render mono tabular numerals (design_system.md tenet #3 '
      '"Data stability"; "mono tabular axis")',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            const VolumeChart(
              data: [
                (label: 'Jun 20', volume: 3200),
                (label: 'Jun 23', volume: 4230),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();
        final label = tester.widget<Text>(find.text('Jun 20'));
        expect(label.style!.fontFamily, 'monospace');
        expect(
          label.style!.fontFeatures,
          contains(const FontFeature.tabularFigures()),
        );
      },
    );

    const sampleData = [
      (label: 'Jun 20', volume: 3200.0),
      (label: 'Jun 23', volume: 4230.0),
      (label: 'Jun 27', volume: 5000.0),
    ];

    testWidgets(
      'AC-003: The latest (last) bar renders at full accent opacity while all '
      'other bars render at accent@0.50',
      (tester) async {
        await tester.pumpWidget(
          _wrap(const VolumeChart(data: sampleData), disableAnimations: true),
        );
        final chartData = tester
            .widget<fl.BarChart>(find.byType(fl.BarChart))
            .data;
        final colors = chartData.barGroups
            .map((g) => g.barRods.single.color)
            .toList();
        for (var i = 0; i < colors.length - 1; i++) {
          expect(colors[i], AppColors.dark.accent.withValues(alpha: 0.50));
        }
        expect(colors.last, AppColors.dark.accent);
      },
    );

    testWidgets('AC-004: Widget renders a faint surface3 baseline', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const VolumeChart(data: sampleData), disableAnimations: true),
      );
      final chartData = tester
          .widget<fl.BarChart>(find.byType(fl.BarChart))
          .data;
      expect(chartData.borderData.show, isTrue);
      final bottom = chartData.borderData.border.bottom;
      expect(bottom.color, AppColors.dark.surface3);
    });

    testWidgets(
      'AC-005: Bars grow from 0 to their target height on load when motion is '
      'not reduced, and render at full height immediately when '
      'MediaQuery.disableAnimations is true',
      (tester) async {
        await tester.pumpWidget(_wrap(const VolumeChart(data: sampleData)));
        final atStart = tester
            .widget<fl.BarChart>(find.byType(fl.BarChart))
            .data
            .barGroups
            .map((g) => g.barRods.single.toY)
            .toList();
        expect(atStart.every((y) => y == 0), isTrue);

        await tester.pumpAndSettle();
        final atEnd = tester
            .widget<fl.BarChart>(find.byType(fl.BarChart))
            .data
            .barGroups
            .map((g) => g.barRods.single.toY)
            .toList();
        expect(atEnd, [3200.0, 4230.0, 5000.0]);

        await tester.pumpWidget(
          _wrap(const VolumeChart(data: sampleData), disableAnimations: true),
        );
        final reducedMotion = tester
            .widget<fl.BarChart>(find.byType(fl.BarChart))
            .data
            .barGroups
            .map((g) => g.barRods.single.toY)
            .toList();
        expect(reducedMotion, [3200.0, 4230.0, 5000.0]);
      },
    );
  });
}
