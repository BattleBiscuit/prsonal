import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/models/exercise.dart';
import 'package:prsonal_app/models/routine_exercise.dart';

void main() {
  group('SetTarget', () {
    test(
      'AC-001: SetTarget.strength() defaults to 10 reps, 0 kg, not bodyweight, and 90 seconds rest',
      () {
        final s = SetTarget.strength();
        expect(s.kind, ExerciseType.strength);
        expect(s.reps, 10);
        expect(s.weight, 0);
        expect(s.isBodyweight, isFalse);
        expect(s.restSeconds, 90);
      },
    );

    test(
      'AC-002: SetTarget.cardio() defaults to 20 minutes duration, level 1, and 0 seconds rest',
      () {
        final s = SetTarget.cardio();
        expect(s.kind, ExerciseType.cardio);
        expect(s.duration, 20);
        expect(s.level, 1);
        expect(s.restSeconds, 0);
      },
    );

    test(
      'AC-003: a strength SetTarget round-trips through JSON preserving reps, weight, isBodyweight and restSeconds',
      () {
        final s = SetTarget.strength().copyWith(
          reps: 8,
          weight: 82.5,
          isBodyweight: true,
          restSeconds: 120,
        );
        final restored = SetTarget.fromJson(s.toJson());
        expect(restored.reps, 8);
        expect(restored.weight, 82.5);
        expect(restored.isBodyweight, isTrue);
        expect(restored.restSeconds, 120);
      },
    );

    test(
      'AC-004: a cardio SetTarget round-trips through JSON preserving duration, level and restSeconds',
      () {
        final s = SetTarget.cardio().copyWith(
          duration: 30,
          level: 5,
          restSeconds: 60,
        );
        final restored = SetTarget.fromJson(s.toJson());
        expect(restored.duration, 30);
        expect(restored.level, 5);
        expect(restored.restSeconds, 60);
      },
    );

    test('AC-005: SetTarget.isCardio is true only when kind is cardio', () {
      expect(SetTarget.cardio().isCardio, isTrue);
      expect(SetTarget.strength().isCardio, isFalse);
    });

    test(
      'AC-006: validateSets returns false for an empty list and true when at least one set is present',
      () {
        expect(validateSets(const []), isFalse);
        expect(validateSets([SetTarget.strength()]), isTrue);
      },
    );
  });
}
