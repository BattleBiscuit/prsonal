import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:prsonal_app/models/exercise.dart';
import 'package:prsonal_app/screens/session_active_screen.dart';
import 'package:prsonal_app/services/session_service.dart';

// Fake engine: returns a canned ActiveSessionState and records mutations.
// markCurrentSetComplete actually advances `state` (marks the current set
// completed, moves the cursor) rather than only logging the call, so tests
// can assert on real derived state (progress, currentSet, isLastSet) instead
// of just "the engine was asked to do something".
class _FakeEngine extends SessionEngine {
  _FakeEngine(this._initial);
  final ActiveSessionState _initial;
  final List<String> calls = [];
  bool? lastIsBodyweight;

  @override
  ActiveSessionState? build() => _initial;

  @override
  Future<bool> markCurrentSetComplete({
    required num actualPrimary,
    required num actualSecondary,
    required bool isBodyweight,
  }) async {
    calls.add('complete');
    lastIsBodyweight = isBodyweight;

    final current = state!;
    final cursor = current.cursor;
    final exercise = current.exercises[cursor.exerciseIndex];
    final updatedSets = [...exercise.sets];
    updatedSets[cursor.setIndex] = updatedSets[cursor.setIndex].copyWith(
      status: ActiveSetStatus.completed,
      actualLabel: '$actualPrimary×${actualSecondary}kg',
      isBodyweight: isBodyweight,
    );
    final updatedExercises = [...current.exercises];
    updatedExercises[cursor.exerciseIndex] = exercise.copyWith(
      sets: updatedSets,
    );

    state = ActiveSessionState(
      session: current.session,
      exercises: updatedExercises,
      cursor: _nextCursor(updatedExercises),
      elapsed: current.elapsed,
      resting: current.resting,
      restRemaining: current.restRemaining,
    );
    return false;
  }

  /// The first active/pending set after the just-completed one, or a
  /// past-the-end cursor when none remain (so `currentSet` is null and
  /// `isLastSet` is true) — mirrors the real engine's cursor-advance intent
  /// closely enough for this screen's tests without reimplementing it.
  SessionCursor _nextCursor(List<ActiveExercise> exercises) {
    for (var ei = 0; ei < exercises.length; ei++) {
      for (var si = 0; si < exercises[ei].sets.length; si++) {
        final status = exercises[ei].sets[si].status;
        if (status == ActiveSetStatus.active ||
            status == ActiveSetStatus.pending) {
          return (exerciseIndex: ei, setIndex: si);
        }
      }
    }
    return (exerciseIndex: exercises.length, setIndex: 0);
  }

  @override
  void cancelRest() => calls.add('cancelRest');

  @override
  Future<void> uncheckSet(int exerciseIndex, int setIndex) async =>
      calls.add('uncheck:$exerciseIndex,$setIndex');

  @override
  void jumpToSet(int exerciseIndex, int setIndex) =>
      calls.add('jump:$exerciseIndex,$setIndex');

  @override
  Future<void> finishSession() async => calls.add('finish');

  @override
  Future<void> abandonSession() async => calls.add('abandon');
}

ActiveSessionState _state({
  bool isLastSet = false,
  bool resting = false,
  int restRemaining = 0,
}) {
  return ActiveSessionState.forTest(
    routineName: 'Push Day A',
    elapsed: const Duration(minutes: 12, seconds: 31),
    progress: 0.5,
    isLastSet: isLastSet,
    resting: resting,
    restRemaining: restRemaining,
    exercises: [
      ActiveExercise.forTest(
        name: 'Bench Press',
        isCurrent: true,
        sets: [
          ActiveSet(
            index: 0,
            kind: ExerciseType.strength,
            plannedLabel: '10×80kg',
            status: ActiveSetStatus.completed,
            actualLabel: '10×80kg',
            isPR: true,
          ),
          ActiveSet(
            index: 1,
            kind: ExerciseType.strength,
            plannedLabel: '8×82.5kg',
            status: ActiveSetStatus.active,
            plannedReps: 8,
            plannedWeight: 82.5,
          ),
        ],
      ),
    ],
  );
}

GoRouter _router(
  _FakeEngine engine, {
  bool isLastSet = false,
  bool resting = false,
  int rest = 0,
}) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        name: 'session-active',
        builder: (_, __) => const SessionActiveScreen(),
      ),
      GoRoute(
        path: '/history',
        name: 'history',
        builder: (_, __) => const Text('HISTORY'),
      ),
      GoRoute(
        path: '/',
        name: 'session-pick',
        builder: (_, __) => const Text('PICK'),
      ),
    ],
  );
}

Future<_FakeEngine> _pump(
  WidgetTester tester, {
  bool isLastSet = false,
  bool resting = false,
  int rest = 0,
}) async {
  final engine = _FakeEngine(
    _state(isLastSet: isLastSet, resting: resting, restRemaining: rest),
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [sessionEngineProvider.overrideWith(() => engine)],
      child: MaterialApp.router(
        // The session heartbeat (LiveDot) breathes on an infinite loop by
        // design (design_system.md "Motion & life"); pumpAndSettle below
        // would never terminate without dropping to the documented
        // reduced-motion behaviour, exactly as it does under the OS
        // "reduce motion" flag.
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: child!,
        ),
        routerConfig: GoRouter(
          routes: [
            GoRoute(
              path: '/',
              name: 'session-active',
              builder: (_, __) => const SessionActiveScreen(),
            ),
            GoRoute(
              path: '/history',
              name: 'history',
              builder: (_, __) => const Text('HISTORY'),
            ),
            GoRoute(
              path: '/pick',
              name: 'session-pick',
              builder: (_, __) => const Text('PICK'),
            ),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return engine;
}

void main() {
  group('SessionActiveScreen', () {
    testWidgets(
      'AC-001: Renders a progress bar reflecting the proportion of completed sets',
      (tester) async {
        await _pump(tester);
        final bar = tester.widget<FractionallySizedBox>(
          find.descendant(
            of: find.byType(SessionActiveScreen),
            matching: find.byType(FractionallySizedBox),
          ),
        );
        expect(bar.widthFactor, 0.5);
      },
    );

    testWidgets(
      'AC-002: The header shows the routine name and the elapsed time, with quit and finish actions',
      (tester) async {
        await _pump(tester);
        expect(find.text('Push Day A'), findsOneWidget);
        expect(find.text('12:31'), findsOneWidget);
        expect(find.bySemanticsLabel('Quit workout'), findsOneWidget);
        expect(find.bySemanticsLabel('Finish workout'), findsOneWidget);
      },
    );

    testWidgets(
      'AC-003: The current set is editable and the bottom action button reads "Done"',
      (tester) async {
        await _pump(tester);
        expect(find.byType(TextField), findsWidgets);
        expect(find.text('Done'), findsOneWidget);
      },
    );

    testWidgets(
      'AC-004: On the final set the bottom action button reads "Finish"',
      (tester) async {
        await _pump(tester, isLastSet: true);
        expect(find.text('Finish'), findsOneWidget);
      },
    );

    testWidgets(
      'AC-005: Completing the current set marks it done with its logged '
      'values and advances the cursor',
      (tester) async {
        final engine = await _pump(tester);
        // Precondition: one of two sets already done.
        final barBefore = tester.widget<FractionallySizedBox>(
          find.descendant(
            of: find.byType(SessionActiveScreen),
            matching: find.byType(FractionallySizedBox),
          ),
        );
        expect(barBefore.widthFactor, 0.5);

        await tester.tap(find.text('Done'));
        await tester.pumpAndSettle();

        expect(engine.calls, contains('complete'));
        // Real advancement, not just a logged call: the set's pre-filled
        // planned values (8 reps × 82.5kg, per AC-011) are now its logged
        // actuals, there's no more active set to edit, and the progress bar
        // reflects both sets done.
        expect(find.text('8×82.5kg'), findsOneWidget);
        expect(find.byType(TextField), findsNothing);
        final barAfter = tester.widget<FractionallySizedBox>(
          find.descendant(
            of: find.byType(SessionActiveScreen),
            matching: find.byType(FractionallySizedBox),
          ),
        );
        expect(barAfter.widthFactor, 1.0);
      },
    );

    testWidgets(
      'AC-006: While resting, the bottom action button shows the remaining rest time and tapping it skips the rest',
      (tester) async {
        final engine = await _pump(tester, resting: true, rest: 45);
        expect(find.text('Rest 45s'), findsOneWidget);
        await tester.tap(find.text('Rest 45s'));
        await tester.pumpAndSettle();
        expect(engine.calls, contains('cancelRest'));
      },
    );

    testWidgets(
      'AC-007: Tapping the finish action opens a confirm-finish modal; confirming finishes the session and navigates to history',
      (tester) async {
        final engine = await _pump(tester);
        await tester.tap(find.bySemanticsLabel('Finish workout'));
        await tester.pumpAndSettle();
        expect(find.text('Finish workout?'), findsOneWidget);
        await tester.tap(find.text('Save to history'));
        await tester.pumpAndSettle();
        expect(engine.calls, contains('finish'));
        expect(find.text('HISTORY'), findsOneWidget);
      },
    );

    testWidgets(
      'AC-008: Tapping the quit action opens a confirm-abandon modal; confirming abandons the session and navigates to session-pick',
      (tester) async {
        final engine = await _pump(tester);
        await tester.tap(find.bySemanticsLabel('Quit workout'));
        await tester.pumpAndSettle();
        expect(find.text('Abandon workout?'), findsOneWidget);
        await tester.tap(find.text('Abandon'));
        await tester.pumpAndSettle();
        expect(engine.calls, contains('abandon'));
        expect(find.text('PICK'), findsOneWidget);
      },
    );

    testWidgets(
      'AC-009: A completed set renders its logged values and a PR indicator when it set a personal record',
      (tester) async {
        await _pump(tester);
        expect(find.text('10×80kg'), findsWidgets);
        expect(find.bySemanticsLabel('Personal record'), findsOneWidget);
      },
    );

    testWidgets('AC-010: Tapping "Add exercise" opens the exercise form', (
      tester,
    ) async {
      await _pump(tester);
      await tester.tap(find.byTooltip('Add exercise'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Add Exercise'), findsOneWidget);
    });

    testWidgets(
      'AC-011: The active set\'s inputs are pre-filled with its planned reps and weight',
      (tester) async {
        await _pump(tester);
        // The active set plans 8 reps × 82.5 kg — both should be seeded into
        // the editable inputs, not just shown as hints.
        expect(find.widgetWithText(TextField, '8'), findsOneWidget);
        expect(find.widgetWithText(TextField, '82.5'), findsOneWidget);
      },
    );

    testWidgets(
      'AC-012: Tapping the active set\'s checkbox completes the current set',
      (tester) async {
        final engine = await _pump(tester);
        await tester.tap(find.bySemanticsLabel('Complete set'));
        await tester.pumpAndSettle();
        expect(engine.calls, contains('complete'));
        // A different tap target than AC-005's bottom button, but must
        // reach the same real completion — not just log the call.
        expect(find.text('8×82.5kg'), findsOneWidget);
      },
    );

    testWidgets(
      'AC-013: Tapping a completed set re-opens it as the active editable set',
      (tester) async {
        final engine = await _pump(tester);
        // The completed set (exercise 0, set 0) shows its logged values.
        await tester.tap(find.text('10×80kg').first);
        await tester.pumpAndSettle();
        expect(engine.calls, contains('uncheck:0,0'));
      },
    );

    testWidgets(
      'AC-014: The active set\'s bodyweight toggle can be flipped per set, and the chosen value is used when the set is completed',
      (tester) async {
        final engine = await _pump(tester);
        // The active set starts non-bodyweight; flip the BW toggle on.
        await tester.tap(find.bySemanticsLabel('Bodyweight'));
        await tester.pumpAndSettle();
        // Complete the set — the engine receives the toggled bodyweight value.
        await tester.tap(find.bySemanticsLabel('Complete set'));
        await tester.pumpAndSettle();
        expect(engine.lastIsBodyweight, isTrue);
      },
    );
  });
}
