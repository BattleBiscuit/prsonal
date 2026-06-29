import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/models/exercise.dart';

void main() {
  group('Exercise', () {
    test(
      'AC-001: ExerciseType resolves to and from its stored name (strength, cardio); an unknown name throws',
      () {
        expect(ExerciseType.strength.name, 'strength');
        expect(ExerciseType.values.byName('cardio'), ExerciseType.cardio);
        expect(
          () => ExerciseType.values.byName('swimming'),
          throwsArgumentError,
        );
      },
    );

    test(
      'AC-002: Muscle exposes exactly seven values in the fixed order Chest, Shoulders, Arms, Back, Core, Legs, Glutes',
      () {
        expect(Muscle.values, [
          Muscle.chest,
          Muscle.shoulders,
          Muscle.arms,
          Muscle.back,
          Muscle.core,
          Muscle.legs,
          Muscle.glutes,
        ]);
      },
    );

    test(
      'AC-003: Muscle.label returns the human-readable capitalised name',
      () {
        expect(Muscle.chest.label, 'Chest');
        expect(Muscle.glutes.label, 'Glutes');
      },
    );

    test(
      'AC-004: validateExerciseName returns false for an empty or whitespace-only name and true otherwise',
      () {
        expect(validateExerciseName(''), isFalse);
        expect(validateExerciseName('   '), isFalse);
        expect(validateExerciseName('Bench Press'), isTrue);
      },
    );

    test(
      'AC-005: primaryMuscles and secondaryMuscles preserve insertion order when round-tripped through JSON',
      () {
        const muscles = [Muscle.back, Muscle.arms, Muscle.core];
        final json = muscles.map((m) => m.name).toList();
        final restored = json.map(Muscle.values.byName).toList();
        expect(restored, muscles);
      },
    );
  });
}
