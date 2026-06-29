import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/models/exercise.dart';
import 'package:prsonal_app/widgets/radar_chart_widget.dart' as app;

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: SizedBox(width: 320, height: 320, child: child)),
);

void main() {
  group('RadarChart', () {
    testWidgets(
      'AC-001: Widget renders a radar chart for the provided muscle data',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            const app.MuscleRadarChart(
              data: {Muscle.chest: 3, Muscle.back: 2, Muscle.legs: 4},
            ),
          ),
        );
        expect(find.byType(fl.RadarChart), findsOneWidget);
      },
    );

    testWidgets(
      'AC-002: Widget shows an empty state when all muscle counts are zero',
      (tester) async {
        await tester.pumpWidget(_wrap(const app.MuscleRadarChart(data: {})));
        expect(find.text('Not enough data yet'), findsOneWidget);
      },
    );
  });
}
