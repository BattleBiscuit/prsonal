import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/widgets/workout_summary_header_widget.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('WorkoutSummaryHeader', () {
    testWidgets('AC-001: Widget renders the date/time line and routine name', (tester) async {
      await tester.pumpWidget(_wrap(const WorkoutSummaryHeader(
        routineName: 'Push Day A',
        dateTimeLabel: 'Mon, 23 Jun at 09:15 AM',
        durationLabel: '47m',
        volumeLabel: '4,230 kg',
        statusLabel: 'Completed',
      )));
      expect(find.text('Push Day A'), findsOneWidget);
      expect(find.text('Mon, 23 Jun at 09:15 AM'), findsOneWidget);
    });

    testWidgets('AC-002: Widget renders three stat tiles for duration, total volume and status',
        (tester) async {
      await tester.pumpWidget(_wrap(const WorkoutSummaryHeader(
        routineName: 'Push Day A',
        dateTimeLabel: 'Mon, 23 Jun at 09:15 AM',
        durationLabel: '47m',
        volumeLabel: '4,230 kg',
        statusLabel: 'Completed',
      )));
      expect(find.text('47m'), findsOneWidget);
      expect(find.text('4,230 kg'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
    });
  });
}
