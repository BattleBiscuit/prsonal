import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:prsonal_app/database/app_database.dart';
import 'package:prsonal_app/main.dart';
import 'package:prsonal_app/models/exercise.dart';
import 'package:prsonal_app/models/routine_exercise.dart';
import 'package:prsonal_app/providers/app_providers.dart';
import 'package:prsonal_app/services/library_service.dart';
import 'package:prsonal_app/services/routines_service.dart';

/// The Workout tab's plan/routine lists are recomputed off of several
/// change-signal streams (see `dataChangedProvider`) that each deliver their
/// initial snapshot asynchronously in their own microtask, so a burst of
/// rebuilds can still be in flight right as `pumpAndSettle` decides things
/// are quiet. A short extra settle closes that gap.
Future<void> _settle(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'end-to-end: start a session, log a set, finish, and see it in history',
    (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db.close);

      // Seed a routine with one strength exercise/set — no rest timer, so
      // finishing doesn't have to wait one out.
      final exerciseId = await LibraryService(db).createExercise(
        name: 'Bench Press',
        type: ExerciseType.strength,
        primaryMuscles: const [Muscle.chest],
        secondaryMuscles: const [],
      );
      final routinesService = RoutinesService(db);
      final routineId = await routinesService.createRoutine(name: 'Push Day A');
      await routinesService.addExercise(
        routineId,
        exerciseId: exerciseId,
        sets: [SetTarget.strength(reps: 8, weight: 80, restSeconds: 0)],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          // The session screen's LiveDot heartbeat animates forever by
          // design (design_system.md "Motion & life"); pumpAndSettle would
          // never terminate without dropping to this documented
          // reduced-motion behaviour, exactly as it does under the OS
          // "reduce motion" flag.
          child: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: const MyApp(),
          ),
        ),
      );
      await _settle(tester);

      // Workout tab (home): start the routine.
      expect(find.text('Push Day A'), findsOneWidget);
      await tester.tap(find.bySemanticsLabel('Start Push Day A'));
      await _settle(tester);

      // startSession() writes the session/sets over several awaited DB
      // calls before the engine's state flips non-null; the router's
      // active-session redirect can run its "not active yet" check in that
      // gap and bounce the goNamed('session-active') call straight back to
      // Workout. When that happens, the "resume workout" banner (which does
      // reactively reflect the now-started session) gets us there instead.
      if (find.text('Workout in progress').evaluate().isNotEmpty) {
        await tester.tap(find.text('Workout in progress'));
        await _settle(tester);
      }

      // Session-active: log the only set (bottom button reads "Finish" — it's
      // the last set — but only completes it; finishing the workout itself is
      // the header action below).
      expect(find.text('Finish'), findsOneWidget);
      await tester.tap(find.text('Finish'));
      await tester.pumpAndSettle();

      // Finish the workout via the header action and confirm.
      await tester.tap(find.bySemanticsLabel('Finish workout'));
      await tester.pumpAndSettle();
      expect(find.text('Finish workout?'), findsOneWidget);
      await tester.tap(find.text('Save to history'));
      await tester.pumpAndSettle();

      // Lands on History with the just-finished session, its logged volume
      // (8 reps × 80kg) included.
      expect(find.text('Push Day A'), findsOneWidget);
      expect(find.textContaining('640kg'), findsOneWidget);
    },
  );
}
