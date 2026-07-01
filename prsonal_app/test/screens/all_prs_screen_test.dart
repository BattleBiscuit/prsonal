import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/providers/progress_providers.dart';
import 'package:prsonal_app/screens/all_prs_screen.dart';
import 'package:prsonal_app/services/progress_service.dart';
import 'package:prsonal_app/widgets/app_skeleton_widget.dart';
import 'package:prsonal_app/widgets/pr_row_widget.dart';

PRItem _pr(
  String name, {
  double oneRepMax = 95,
  int reps = 5,
  double weight = 90,
  bool isBodyweight = false,
  DateTime? date,
}) => PRItem(
  exerciseName: name,
  oneRepMax: oneRepMax,
  reps: reps,
  weight: weight,
  isBodyweight: isBodyweight,
  date: date ?? DateTime(2026, 6, 23),
);

Future<void> _pump(WidgetTester tester, List<PRItem> prs) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [allPrsProvider.overrideWith((ref) async => prs)],
      child: const MaterialApp(home: AllPrsScreen()),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('AllPrsScreen', () {
    testWidgets('AC-001: Lists the best PR per exercise as a PR row', (
      tester,
    ) async {
      await _pump(tester, [_pr('Bench Press'), _pr('Squat')]);
      expect(find.byType(PrRow), findsNWidgets(2));
    });

    testWidgets(
      'AC-001: Each PR row shows the exercise name, date, weight and estimated 1RM',
      (tester) async {
        await _pump(tester, [
          _pr(
            'Bench Press',
            oneRepMax: 102.5,
            reps: 5,
            weight: 90,
            date: DateTime(2026, 6, 23),
          ),
        ]);
        expect(find.text('Bench Press'), findsOneWidget);
        expect(find.text('23 Jun 2026'), findsOneWidget);
        expect(find.text('90.0kg'), findsOneWidget);
        expect(find.text('1RM: 102.5kg'), findsOneWidget);
      },
    );

    testWidgets(
      'AC-001: Rows render in the order the provider returns (best PR per exercise, ranked by 1RM)',
      (tester) async {
        await _pump(tester, [
          _pr('Squat', oneRepMax: 140),
          _pr('Bench Press', oneRepMax: 102.5),
          _pr('Deadlift', oneRepMax: 180),
        ]);
        final names = tester
            .widgetList<Text>(find.byType(Text))
            .map((w) => w.data)
            .whereType<String>()
            .toList();
        expect(
          names.indexOf('Squat') < names.indexOf('Bench Press') &&
              names.indexOf('Bench Press') < names.indexOf('Deadlift'),
          isTrue,
        );
      },
    );

    testWidgets(
      'AC-001: Rows for different exercises are separated by a divider',
      (tester) async {
        await _pump(tester, [_pr('Bench Press'), _pr('Squat'), _pr('Row')]);
        expect(find.byType(Divider), findsNWidgets(2));
      },
    );

    testWidgets('AC-002: Shows an empty state when there are no PRs', (
      tester,
    ) async {
      await _pump(tester, const []);
      expect(find.text('No personal records yet'), findsOneWidget);
      expect(find.byType(PrRow), findsNothing);
    });

    testWidgets('Shows a skeleton loader while the PR list is loading', (
      tester,
    ) async {
      final completer = Completer<List<PRItem>>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [allPrsProvider.overrideWith((ref) => completer.future)],
          child: const MaterialApp(home: AllPrsScreen()),
        ),
      );
      await tester.pump();
      expect(find.byType(AppSkeleton), findsWidgets);
      expect(find.byType(PrRow), findsNothing);

      completer.complete([_pr('Bench Press')]);
      await tester.pumpAndSettle();
      expect(find.byType(PrRow), findsOneWidget);
    });

    testWidgets('Shows an error message when the PR list fails to load', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            allPrsProvider.overrideWith((ref) async => throw Exception('boom')),
          ],
          child: const MaterialApp(home: AllPrsScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Error'), findsOneWidget);
    });
  });
}
