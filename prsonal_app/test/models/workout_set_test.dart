import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/models/exercise.dart';
import 'package:prsonal_app/models/workout_math.dart';
import 'package:prsonal_app/models/workout_set.dart';

void main() {
  group('WorkoutSet', () {
    test(
      'AC-001: workoutSetIsComplete is true when the set has a completedAt and is not skipped',
      () {
        expect(
          workoutSetIsComplete(
            completedAt: DateTime(2026, 6, 23),
            skipped: false,
          ),
          isTrue,
        );
      },
    );

    test(
      'AC-002: workoutSetIsComplete is false when the set is skipped even if completedAt is set',
      () {
        expect(
          workoutSetIsComplete(
            completedAt: DateTime(2026, 6, 23),
            skipped: true,
          ),
          isFalse,
        );
        expect(
          workoutSetIsComplete(completedAt: null, skipped: false),
          isFalse,
        );
      },
    );

    test('AC-003: formatStrengthSet renders reps and weight as "10×80kg"', () {
      expect(
        formatStrengthSet(reps: 10, weight: 80, isBodyweight: false),
        '10×80kg',
      );
    });

    test(
      'AC-004: formatStrengthSet renders a bodyweight set as "10×BW+10kg"',
      () {
        expect(
          formatStrengthSet(reps: 10, weight: 10, isBodyweight: true),
          '10×BW+10kg',
        );
      },
    );

    test(
      'AC-005: formatCardioSet renders duration and level as "30min · lvl5"',
      () {
        expect(formatCardioSet(duration: 30, level: 5), '30min · lvl5');
      },
    );

    test(
      'AC-006: setEstimatedOneRepMax returns null for a cardio set and the Epley 1RM for a completed strength set',
      () {
        expect(
          setEstimatedOneRepMax(
            type: ExerciseType.cardio,
            effectiveWeight: null,
            actualReps: null,
          ),
          isNull,
        );
        expect(
          setEstimatedOneRepMax(
            type: ExerciseType.strength,
            effectiveWeight: 100,
            actualReps: 5,
          ),
          closeTo(estimatedOneRepMax(effectiveWeight: 100, reps: 5), 1e-9),
        );
      },
    );
  });
}
