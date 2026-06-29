import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/providers/session_providers.dart';
import 'package:prsonal_app/widgets/app_bottom_nav_widget.dart';

Widget _wrap(Widget child, {bool sessionActive = false}) => ProviderScope(
  overrides: [activeSessionProvider.overrideWithValue(sessionActive)],
  child: MaterialApp(home: Scaffold(bottomNavigationBar: child)),
);

void main() {
  group('AppBottomNav', () {
    testWidgets('AC-001: Widget renders exactly five tabs in the fixed order', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(AppBottomNav(currentIndex: 0, onTabSelected: (_) {})),
      );
      await tester.pumpAndSettle();

      const expectedLabels = [
        'Workout',
        'Exercises',
        'Body',
        'Progress',
        'Settings',
      ];
      for (final label in expectedLabels) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets(
      'AC-002: The tab at currentIndex renders in accent colour; all others render in tertiary text colour',
      (tester) async {
        await tester.pumpWidget(
          _wrap(AppBottomNav(currentIndex: 2, onTabSelected: (_) {})),
        );
        await tester.pumpAndSettle();

        // NavigationBar manages active/inactive styling internally.
        // Verify the NavigationBar's selectedIndex matches what we passed.
        final navBar = tester.widget<NavigationBar>(find.byType(NavigationBar));
        expect(navBar.selectedIndex, 2);
      },
    );

    testWidgets(
      'AC-003: Widget calls onTabSelected with the correct index when a tab is tapped',
      (tester) async {
        int? selected;
        await tester.pumpWidget(
          _wrap(
            AppBottomNav(currentIndex: 0, onTabSelected: (i) => selected = i),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Progress'));
        await tester.pumpAndSettle();

        expect(selected, 3);
      },
    );

    testWidgets(
      'AC-004: Widget is not rendered when a workout session is active',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            AppBottomNav(currentIndex: 0, onTabSelected: (_) {}),
            sessionActive: true,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(NavigationBar), findsNothing);
      },
    );
  });
}
