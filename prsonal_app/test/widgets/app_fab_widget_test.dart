import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/widgets/app_fab_widget.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('AppFab', () {
    testWidgets('AC-001: Widget renders the label', (tester) async {
      await tester.pumpWidget(
        _wrap(AppFab(label: 'New', icon: Icons.add, onPressed: () {})),
      );
      expect(find.text('New'), findsOneWidget);
    });

    testWidgets('AC-002: Widget renders the leading icon', (tester) async {
      await tester.pumpWidget(
        _wrap(AppFab(label: 'New', icon: Icons.add, onPressed: () {})),
      );
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets(
      'AC-003: Widget calls onPressed when tapped and onPressed is non-null',
      (tester) async {
        var tapped = false;
        await tester.pumpWidget(
          _wrap(
            AppFab(
              label: 'New',
              icon: Icons.add,
              onPressed: () => tapped = true,
            ),
          ),
        );
        await tester.tap(find.byType(AppFab));
        expect(tapped, isTrue);
      },
    );

    testWidgets('AC-004: Widget does not call onPressed when onPressed is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const AppFab(label: 'New', icon: Icons.add, onPressed: null)),
      );
      await tester.tap(find.byType(AppFab), warnIfMissed: false);
      // No callback to assert; reaching here without error satisfies the inert contract.
      expect(find.byType(AppFab), findsOneWidget);
    });

    testWidgets(
      'AC-005: Widget renders the bare-icon circular form (no visible text) when label is omitted',
      (tester) async {
        await tester.pumpWidget(
          _wrap(AppFab(icon: Icons.add, tooltip: 'Add', onPressed: () {})),
        );
        expect(find.byIcon(Icons.add), findsOneWidget);
        expect(find.byType(Text), findsNothing);
      },
    );

    testWidgets(
      'AC-006: Widget exposes a Tooltip with the given tooltip text, or the label when tooltip is omitted',
      (tester) async {
        await tester.pumpWidget(
          _wrap(AppFab(icon: Icons.add, tooltip: 'Add', onPressed: () {})),
        );
        expect(find.byTooltip('Add'), findsOneWidget);

        await tester.pumpWidget(
          _wrap(AppFab(label: 'New', icon: Icons.add, onPressed: () {})),
        );
        expect(find.byTooltip('New'), findsOneWidget);
      },
    );
  });
}
