import 'package:fl_chart/fl_chart.dart' as fl;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/models/exercise.dart';
import 'package:prsonal_app/theme/app_motion.dart';
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

    testWidgets(
      'AC-001: renders the radar with fewer than 3 trained muscles (all 7 axes)',
      (tester) async {
        // fl_chart throws for a RadarDataSet with 1–2 entries; plotting all
        // seven fixed axes keeps the dataset valid regardless of how many
        // muscles have data.
        await tester.pumpWidget(
          _wrap(
            const app.MuscleRadarChart(data: {Muscle.chest: 3, Muscle.legs: 2}),
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.byType(fl.RadarChart), findsOneWidget);
      },
    );

    testWidgets(
      'AC-004: Axis labels are never rotated — each title\'s angle is 0 '
      'regardless of its position around the chart',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            const app.MuscleRadarChart(
              data: {Muscle.chest: 3, Muscle.back: 2, Muscle.legs: 4},
            ),
          ),
        );
        final chart = tester.widget<fl.RadarChart>(find.byType(fl.RadarChart));
        final getTitle = chart.data.getTitle!;
        for (var i = 0; i < 7; i++) {
          // Pass a non-zero radial angle for each axis — the widget must
          // ignore it and always render the label upright.
          final title = getTitle(i, i * 360 / 7);
          expect(title.angle, 0);
        }
      },
    );

    testWidgets(
      'AC-003: Widget scales in from 0 to 1 over AppDurations.normal on load',
      (tester) async {
        await tester.pumpWidget(
          _wrap(const app.MuscleRadarChart(data: {Muscle.chest: 3})),
        );
        final scaleFinder = find.byKey(const ValueKey('radarChartScale'));
        await tester.pump(Duration.zero);
        final scaleAt0 = tester.widget<Transform>(scaleFinder).transform;
        expect(scaleAt0.storage[0], 0.0);

        await tester.pump(AppDurations.normal);
        final scaleAtEnd = tester.widget<Transform>(scaleFinder).transform;
        expect(scaleAtEnd.storage[0], 1.0);
      },
    );
  });
}
