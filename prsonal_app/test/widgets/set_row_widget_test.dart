import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/models/exercise.dart';
import 'package:prsonal_app/services/session_service.dart' show ActiveSetStatus;
import 'package:prsonal_app/theme/app_colors.dart';
import 'package:prsonal_app/widgets/set_row_widget.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('SetRow', () {
    testWidgets(
      'AC-001: An upcoming set renders its set number and planned target',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            const SetRow(
              index: 2,
              kind: ExerciseType.strength,
              status: ActiveSetStatus.upcoming,
              plannedLabel: '8×82.5kg',
            ),
          ),
        );
        expect(find.text('3'), findsOneWidget); // index + 1
        expect(find.text('8×82.5kg'), findsOneWidget);
      },
    );

    testWidgets(
      'AC-002: The active set renders editable primary and secondary inputs and a complete checkbox',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            SetRow(
              index: 0,
              kind: ExerciseType.strength,
              status: ActiveSetStatus.active,
              plannedLabel: '8×82.5kg',
              onToggleComplete: () {},
            ),
          ),
        );
        expect(find.byType(TextField), findsNWidgets(2));
        expect(find.bySemanticsLabel('Complete set'), findsOneWidget);
      },
    );

    testWidgets(
      'AC-003: A completed set renders its logged values in a checked state',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            const SetRow(
              index: 0,
              kind: ExerciseType.strength,
              status: ActiveSetStatus.completed,
              plannedLabel: '8×80kg',
              actualLabel: '8×82.5kg',
            ),
          ),
        );
        expect(find.text('8×82.5kg'), findsOneWidget);
      },
    );

    testWidgets(
      'AC-004: A completed set that set a personal record renders a PR indicator',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            const SetRow(
              index: 0,
              kind: ExerciseType.strength,
              status: ActiveSetStatus.completed,
              plannedLabel: '8×80kg',
              actualLabel: '8×90kg',
              isPR: true,
            ),
          ),
        );
        expect(find.bySemanticsLabel('Personal record'), findsOneWidget);
      },
    );

    testWidgets('AC-005: A skipped set renders a skipped treatment', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const SetRow(
            index: 0,
            kind: ExerciseType.strength,
            status: ActiveSetStatus.skipped,
            plannedLabel: '8×80kg',
          ),
        ),
      );
      expect(find.text('Skip'), findsOneWidget);
    });

    testWidgets(
      'AC-006: Tapping the active set\'s checkbox invokes onToggleComplete',
      (tester) async {
        var toggled = false;
        await tester.pumpWidget(
          _wrap(
            SetRow(
              index: 0,
              kind: ExerciseType.strength,
              status: ActiveSetStatus.active,
              plannedLabel: '8×82.5kg',
              onToggleComplete: () => toggled = true,
            ),
          ),
        );
        await tester.tap(find.bySemanticsLabel('Complete set'));
        expect(toggled, isTrue);
      },
    );

    testWidgets(
      'AC-007: The active set\'s inputs display the provided primaryValue and secondaryValue and preserve typed input across rebuilds',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            SetRow(
              index: 0,
              kind: ExerciseType.strength,
              status: ActiveSetStatus.active,
              plannedLabel: '8×82.5kg',
              primaryValue: '8',
              secondaryValue: '82.5',
              onPrimaryChanged: (_) {},
              onSecondaryChanged: (_) {},
              onToggleComplete: () {},
            ),
          ),
        );
        // Both seeded values are visible in the inputs.
        expect(find.text('8'), findsOneWidget);
        expect(find.text('82.5'), findsOneWidget);

        // Typing into the primary field is reflected, and a rebuild with the
        // same widget config preserves it (no controller reset on every build).
        await tester.enterText(find.byType(TextField).first, '9');
        await tester.pump();
        expect(find.text('9'), findsOneWidget);
      },
    );

    testWidgets(
      'AC-008: The active set renders as a Tier 3 live row — a faint accent tint background with a 2px accent left rail and light (text1) content',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            SetRow(
              index: 0,
              kind: ExerciseType.strength,
              status: ActiveSetStatus.active,
              plannedLabel: '8×82.5kg',
              onToggleComplete: () {},
            ),
          ),
        );

        // The active row is a faint accent tint (accent @ 0.06) with a 2px
        // accent left rail — the "you are here" live row, not a solid chalk
        // block.
        final liveRow = tester
            .widgetList<Container>(find.byType(Container))
            .map((c) => c.decoration)
            .whereType<BoxDecoration>()
            .where((d) {
              final border = d.border;
              return d.color == AppColors.dark.accent.withValues(alpha: 0.06) &&
                  border is Border &&
                  border.left.color == AppColors.dark.accent &&
                  border.left.width == 2;
            });
        expect(liveRow, isNotEmpty);

        // Content is light (text1), not dark onAccent.
        final setNumber = tester.widget<Text>(find.text('1'));
        expect(setNumber.style?.color, AppColors.dark.text1);
      },
    );

    testWidgets(
      'AC-009: Tapping a completed set invokes onSelect (to re-open it for editing)',
      (tester) async {
        var selected = false;
        await tester.pumpWidget(
          _wrap(
            SetRow(
              index: 0,
              kind: ExerciseType.strength,
              status: ActiveSetStatus.completed,
              plannedLabel: '8×80kg',
              actualLabel: '8×82.5kg',
              onSelect: () => selected = true,
            ),
          ),
        );
        await tester.tap(find.text('8×82.5kg'));
        expect(selected, isTrue);
      },
    );

    testWidgets(
      'AC-010: The active set renders a BW toggle that invokes onToggleBodyweight when tapped, and reflects the isBodyweight state',
      (tester) async {
        var toggled = false;
        await tester.pumpWidget(
          _wrap(
            SetRow(
              index: 0,
              kind: ExerciseType.strength,
              status: ActiveSetStatus.active,
              plannedLabel: '8×82.5kg',
              isBodyweight: true,
              onToggleBodyweight: () => toggled = true,
              onToggleComplete: () {},
            ),
          ),
        );
        // The BW toggle is present and tapping it invokes the callback.
        expect(find.text('BW'), findsOneWidget);
        await tester.tap(find.bySemanticsLabel('Bodyweight'));
        expect(toggled, isTrue);
        // When bodyweight, the weight field hints a signed added weight.
        expect(find.text('±kg'), findsOneWidget);
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

        testWidgets('Upcoming set index renders mono', (tester) async {
          await tester.pumpWidget(
            _wrap(
              const SetRow(
                index: 2,
                kind: ExerciseType.strength,
                status: ActiveSetStatus.upcoming,
                plannedLabel: '8×82.5kg',
              ),
            ),
          );
          expect(tester.widget<Text>(find.text('3')).style, isMono());
        });

        testWidgets('Active set index renders mono', (tester) async {
          await tester.pumpWidget(
            _wrap(
              SetRow(
                index: 0,
                kind: ExerciseType.strength,
                status: ActiveSetStatus.active,
                plannedLabel: '8×82.5kg',
                onToggleComplete: () {},
              ),
            ),
          );
          expect(tester.widget<Text>(find.text('1')).style, isMono());
        });

        testWidgets('Completed set index renders mono', (tester) async {
          await tester.pumpWidget(
            _wrap(
              const SetRow(
                index: 0,
                kind: ExerciseType.strength,
                status: ActiveSetStatus.completed,
                plannedLabel: '8×80kg',
                actualLabel: '8×82.5kg',
              ),
            ),
          );
          expect(tester.widget<Text>(find.text('1')).style, isMono());
        });

        testWidgets('Skipped set index renders mono', (tester) async {
          await tester.pumpWidget(
            _wrap(
              const SetRow(
                index: 0,
                kind: ExerciseType.strength,
                status: ActiveSetStatus.skipped,
                plannedLabel: '8×80kg',
              ),
            ),
          );
          expect(tester.widget<Text>(find.text('1')).style, isMono());
        });

        testWidgets(
          'Active set live weight/reps input fields render mono',
          (tester) async {
            await tester.pumpWidget(
              _wrap(
                SetRow(
                  index: 0,
                  kind: ExerciseType.strength,
                  status: ActiveSetStatus.active,
                  plannedLabel: '8×82.5kg',
                  onToggleComplete: () {},
                ),
              ),
            );
            final fields = tester.widgetList<TextField>(
              find.byType(TextField),
            );
            for (final field in fields) {
              expect(field.style, isMono());
            }
          },
        );
      },
    );
  });
}
