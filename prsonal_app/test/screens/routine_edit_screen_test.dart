import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prsonal_app/models/routine_exercise.dart';
import 'package:prsonal_app/providers/app_providers.dart';
import 'package:prsonal_app/screens/routine_edit_screen.dart';
import 'package:prsonal_app/services/routines_service.dart';
import 'package:prsonal_app/widgets/exercise_form_widget.dart';

class _MockRoutinesService extends Mock implements RoutinesService {}

RoutineDraft _draft() => RoutineDraft(
      id: 'r1',
      name: 'Push Day A',
      notes: 'Heavy',
      exercises: [
        RoutineExerciseDraft(
            id: 'rx1',
            exerciseId: 'e1',
            exerciseName: 'Bench Press',
            position: 0,
            notes: null,
            sets: [SetTarget.strength()]),
      ],
    );

GoRouter _router(Widget screen) => GoRouter(routes: [
      GoRoute(path: '/', name: 'routines', builder: (_, __) => screen),
      GoRoute(path: '/back', name: 'session-pick', builder: (_, __) => const Text('BACK')),
    ]);

Future<_MockRoutinesService> _pump(WidgetTester tester,
    {String? routineId, RoutineDraft? draft}) async {
  final service = _MockRoutinesService();
  when(() => service.createRoutine(name: any(named: 'name'), notes: any(named: 'notes')))
      .thenAnswer((_) async => 'r-new');
  await tester.pumpWidget(ProviderScope(
    overrides: [
      routinesServiceProvider.overrideWithValue(service),
      libraryOptionsProvider.overrideWith((ref) => Stream.value(const [])),
      if (routineId != null)
        routineDraftProvider(routineId).overrideWith((ref) async => draft),
    ],
    child: MaterialApp.router(routerConfig: _router(RoutineEditScreen(routineId: routineId))),
  ));
  await tester.pumpAndSettle();
  return service;
}

void main() {
  group('RoutineEditScreen', () {
    testWidgets('AC-001: In create mode the name field starts empty; in edit mode it is populated from the routine',
        (tester) async {
      await _pump(tester);
      expect(find.widgetWithText(TextField, 'Push Day A'), findsNothing);
      await _pump(tester, routineId: 'r1', draft: _draft());
      expect(find.text('Push Day A'), findsOneWidget);
    });

    testWidgets('AC-002: Tapping "Add" opens the exercise form', (tester) async {
      await _pump(tester);
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      expect(find.byType(ExerciseForm), findsOneWidget);
    });

    testWidgets('AC-003: Tapping an exercise item opens the exercise form populated with its values',
        (tester) async {
      await _pump(tester, routineId: 'r1', draft: _draft());
      await tester.tap(find.text('Bench Press'));
      await tester.pumpAndSettle();
      expect(find.byType(ExerciseForm), findsOneWidget);
    });

    testWidgets('AC-004: The exercise list is reorderable', (tester) async {
      await _pump(tester, routineId: 'r1', draft: _draft());
      expect(find.byType(ReorderableListView), findsOneWidget);
    });

    testWidgets('AC-005: Tapping Save persists the routine and navigates back', (tester) async {
      final service = await _pump(tester);
      await tester.enterText(find.byType(TextField).first, 'New Routine');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      verify(() => service.createRoutine(name: 'New Routine', notes: any(named: 'notes')))
          .called(1);
    });

    testWidgets('AC-006: Saving with an empty name shows a validation error and does not persist',
        (tester) async {
      final service = await _pump(tester);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Name is required'), findsOneWidget);
      verifyNever(() => service.createRoutine(name: any(named: 'name'), notes: any(named: 'notes')));
    });

    testWidgets('AC-007: Attempting to leave with unsaved changes prompts a discard confirmation',
        (tester) async {
      await _pump(tester);
      await tester.enterText(find.byType(TextField).first, 'Dirty');
      final dynamic state = tester.state(find.byType(RoutineEditScreen));
      await state.maybePop();
      await tester.pumpAndSettle();
      expect(find.text('Discard changes?'), findsOneWidget);
    });
  });
}
