import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/providers/progress_providers.dart';
import 'package:prsonal_app/screens/all_prs_screen.dart';
import 'package:prsonal_app/services/progress_service.dart';
import 'package:prsonal_app/widgets/pr_row_widget.dart';

PRItem _pr(String name) => PRItem(
    exerciseName: name,
    oneRepMax: 95,
    reps: 5,
    weight: 90,
    isBodyweight: false,
    date: DateTime(2026, 6, 23));

Future<void> _pump(WidgetTester tester, List<PRItem> prs) async {
  await tester.pumpWidget(ProviderScope(
    overrides: [allPrsProvider.overrideWith((ref) async => prs)],
    child: const MaterialApp(home: AllPrsScreen()),
  ));
  await tester.pumpAndSettle();
}

void main() {
  group('AllPrsScreen', () {
    testWidgets('AC-001: Lists the best PR per exercise as a PR row', (tester) async {
      await _pump(tester, [_pr('Bench Press'), _pr('Squat')]);
      expect(find.byType(PrRow), findsNWidgets(2));
    });

    testWidgets('AC-002: Shows an empty state when there are no PRs', (tester) async {
      await _pump(tester, const []);
      expect(find.text('No personal records yet'), findsOneWidget);
    });
  });
}
