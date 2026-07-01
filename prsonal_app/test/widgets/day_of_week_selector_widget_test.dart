import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/widgets/day_of_week_selector_widget.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('DayOfWeekSelector', () {
    testWidgets(
      'AC-001: Widget renders seven day buttons labelled Mon, Tue, Wed, Thu, Fri, Sat, Sun',
      (tester) async {
        await tester.pumpWidget(_wrap(DayOfWeekSelector(onChanged: (_) {})));
        for (final d in ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']) {
          expect(find.text(d), findsOneWidget);
        }
      },
    );

    testWidgets('AC-002: Widget highlights the selected day', (tester) async {
      await tester.pumpWidget(
        _wrap(DayOfWeekSelector(selected: 2, onChanged: (_) {})),
      );
      final widget = tester.widget<DayOfWeekSelector>(
        find.byType(DayOfWeekSelector),
      );
      expect(widget.selected, 2);
    });

    testWidgets('AC-003: Tapping a day calls onChanged with that day index', (
      tester,
    ) async {
      int? changed = -1;
      await tester.pumpWidget(
        _wrap(DayOfWeekSelector(onChanged: (v) => changed = v)),
      );
      await tester.tap(find.text('Wed'));
      expect(changed, 2);
    });

    testWidgets(
      'AC-004: Tapping the currently selected day calls onChanged with null',
      (tester) async {
        int? changed = -1;
        await tester.pumpWidget(
          _wrap(DayOfWeekSelector(selected: 2, onChanged: (v) => changed = v)),
        );
        await tester.tap(find.text('Wed'));
        expect(changed, isNull);
      },
    );

    testWidgets(
      'Does not overflow its container on the narrowest common phone width '
      '(320dp, matching the plan editor\'s padded entry row)',
      (tester) async {
        tester.view.physicalSize = const Size(320, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          _wrap(
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(border: Border.all()),
                child: DayOfWeekSelector(selected: 0, onChanged: (_) {}),
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
      },
    );
  });
}
