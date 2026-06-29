import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/widgets/volume_chart_widget.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: SizedBox(width: 320, height: 240, child: child)),
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
  });
}
