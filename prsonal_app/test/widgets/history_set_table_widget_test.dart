import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/models/exercise.dart';
import 'package:prsonal_app/widgets/history_set_table_widget.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

const _rows = [
  SetTableRow(
    setIndex: 0,
    plannedLabel: '8×80kg',
    actualLabel: '8×82.5kg',
    skipped: false,
    isPR: true,
    kind: ExerciseType.strength,
  ),
  SetTableRow(
    setIndex: 1,
    plannedLabel: '8×80kg',
    actualLabel: null,
    skipped: true,
    isPR: false,
    kind: ExerciseType.strength,
  ),
];

void main() {
  group('HistorySetTable', () {
    testWidgets(
      'AC-001: Widget renders the exercise name and a row per set with planned and actual values',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            const HistorySetTable(exerciseName: 'Bench Press', rows: _rows),
          ),
        );
        expect(find.text('Bench Press'), findsOneWidget);
        expect(find.text('8×82.5kg'), findsOneWidget);
      },
    );

    testWidgets('AC-002: A PR set shows a PR indicator', (tester) async {
      await tester.pumpWidget(
        _wrap(const HistorySetTable(exerciseName: 'Bench Press', rows: _rows)),
      );
      expect(find.bySemanticsLabel('Personal record'), findsOneWidget);
    });

    testWidgets('AC-003: A skipped set is shown distinctly', (tester) async {
      await tester.pumpWidget(
        _wrap(const HistorySetTable(exerciseName: 'Bench Press', rows: _rows)),
      );
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets(
      'AC-004: In editing mode the actual values become editable inputs',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            const HistorySetTable(
              exerciseName: 'Bench Press',
              rows: _rows,
              editing: true,
            ),
          ),
        );
        expect(find.byType(TextField), findsWidgets);
      },
    );

    group(
      'Mono tabular numerals (design_system.md tenet #3 "Data stability")',
      () {
        Matcher isMono() => isA<TextStyle>()
            .having((s) => s.fontFamily, 'fontFamily', 'monospace')
            .having(
              (s) => s.fontFeatures,
              'fontFeatures',
              contains(const FontFeature.tabularFigures()),
            );

        testWidgets('Set index renders mono', (tester) async {
          await tester.pumpWidget(
            _wrap(
              const HistorySetTable(exerciseName: 'Bench Press', rows: _rows),
            ),
          );
          expect(tester.widget<Text>(find.text('1')).style, isMono());
        });

        testWidgets('Read-only actual-value readout renders mono', (
          tester,
        ) async {
          await tester.pumpWidget(
            _wrap(
              const HistorySetTable(exerciseName: 'Bench Press', rows: _rows),
            ),
          );
          expect(tester.widget<Text>(find.text('8×82.5kg')).style, isMono());
        });

        testWidgets('Editable actual-value input renders mono', (tester) async {
          await tester.pumpWidget(
            _wrap(
              const HistorySetTable(
                exerciseName: 'Bench Press',
                rows: _rows,
                editing: true,
              ),
            ),
          );
          final fields = tester.widgetList<TextField>(find.byType(TextField));
          for (final field in fields) {
            expect(field.style, isMono());
          }
        });
      },
    );
  });
}
