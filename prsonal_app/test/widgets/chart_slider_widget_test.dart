import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/widgets/chart_slider_widget.dart';

Widget _wrap(Widget child) => MaterialApp(
  home: Scaffold(body: SizedBox(width: 400, child: child)),
);

ChartSlider _slider() => const ChartSlider(
  titles: ['Muscle balance', 'Volume'],
  pages: [Text('PAGE ONE'), Text('PAGE TWO')],
);

void main() {
  group('ChartSlider', () {
    testWidgets('AC-001: Widget renders the first page and its title', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_slider()));
      expect(find.text('PAGE ONE'), findsOneWidget);
      expect(find.text('Muscle balance'), findsOneWidget);
    });

    testWidgets('AC-002: Widget renders one pagination dot per page', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_slider()));
      expect(find.byKey(const Key('chart-slider-dot')), findsNWidgets(2));
    });

    testWidgets('AC-003: Swiping advances to the next page', (tester) async {
      await tester.pumpWidget(_wrap(_slider()));
      await tester.drag(find.byType(ChartSlider), const Offset(-400, 0));
      await tester.pumpAndSettle();
      expect(find.text('PAGE TWO'), findsOneWidget);
    });

    testWidgets('AC-004: Tapping a pagination dot jumps to that page', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(_slider()));
      await tester.tap(find.byKey(const Key('chart-slider-dot')).last);
      await tester.pumpAndSettle();
      expect(find.text('PAGE TWO'), findsOneWidget);
    });
  });
}
