import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:prsonal_app/models/exercise.dart';
import 'package:prsonal_app/providers/app_providers.dart';
import 'package:prsonal_app/screens/library_screen.dart';
import 'package:prsonal_app/services/library_service.dart';
import 'package:prsonal_app/widgets/library_exercise_form_widget.dart';

class _MockLibraryService extends Mock implements LibraryService {}

LibraryExercise _ex(String id, String name) => LibraryExercise(
  id: id,
  name: name,
  type: ExerciseType.strength,
  primaryMuscles: const [Muscle.chest],
  secondaryMuscles: const [],
  notes: null,
  bestOneRepMax: null,
);

Future<_MockLibraryService> _pump(
  WidgetTester tester,
  List<LibraryExercise> exercises,
) async {
  final service = _MockLibraryService();
  when(() => service.deleteExercise(any())).thenAnswer((_) async {});
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        libraryServiceProvider.overrideWithValue(service),
        libraryListProvider.overrideWith((ref) => Stream.value(exercises)),
      ],
      child: const MaterialApp(home: LibraryScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return service;
}

void main() {
  group('LibraryScreen', () {
    testWidgets(
      'AC-001: Lists exercises, each with its type and primary muscles',
      (tester) async {
        await _pump(tester, [_ex('e1', 'Bench Press'), _ex('e2', 'Squat')]);
        expect(find.text('Bench Press'), findsOneWidget);
        expect(find.text('Squat'), findsOneWidget);
      },
    );

    testWidgets('AC-002: Typing in the search filters the list', (
      tester,
    ) async {
      await _pump(tester, [_ex('e1', 'Bench Press'), _ex('e2', 'Squat')]);
      await tester.enterText(find.byType(TextField).first, 'squ');
      await tester.pumpAndSettle();
      expect(find.text('Squat'), findsOneWidget);
      expect(find.text('Bench Press'), findsNothing);
    });

    testWidgets(
      'AC-003: Tapping the FAB opens the exercise form to create a new exercise',
      (tester) async {
        await _pump(tester, [_ex('e1', 'Bench Press')]);
        await tester.tap(find.byTooltip('New exercise'));
        await tester.pumpAndSettle();
        expect(find.byType(LibraryExerciseForm), findsOneWidget);
      },
    );

    testWidgets('AC-004: Tapping a card opens the exercise form to edit it', (
      tester,
    ) async {
      await _pump(tester, [_ex('e1', 'Bench Press')]);
      await tester.tap(find.text('Bench Press'));
      await tester.pumpAndSettle();
      expect(find.byType(LibraryExerciseForm), findsOneWidget);
    });

    testWidgets(
      'AC-005: Tapping delete confirms and then removes the exercise',
      (tester) async {
        final service = await _pump(tester, [_ex('e1', 'Bench Press')]);
        await tester.tap(find.bySemanticsLabel('Delete exercise'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();
        verify(() => service.deleteExercise('e1')).called(1);
      },
    );

    testWidgets('AC-006: Shows an empty state when the library is empty', (
      tester,
    ) async {
      await _pump(tester, const []);
      expect(find.text('No exercises yet'), findsOneWidget);
    });
  });
}
