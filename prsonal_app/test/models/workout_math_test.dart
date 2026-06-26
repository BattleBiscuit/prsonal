import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/models/workout_math.dart';

void main() {
  group('workout_math', () {
    test('AC-001: resolveEffectiveWeight returns the actual weight unchanged when the set is not bodyweight-relative',
        () {
      expect(
        resolveEffectiveWeight(
            isBodyweight: false, actualWeight: 80, bodyweight: 75),
        80,
      );
    });

    test('AC-002: resolveEffectiveWeight returns bodyweight plus the actual weight when the set is bodyweight-relative',
        () {
      expect(
        resolveEffectiveWeight(
            isBodyweight: true, actualWeight: 10, bodyweight: 75),
        85,
      );
    });

    test('AC-003: estimatedOneRepMax returns the effective weight unchanged when reps equals 1',
        () {
      expect(estimatedOneRepMax(effectiveWeight: 100, reps: 1), 100);
    });

    test('AC-004: estimatedOneRepMax applies the Epley formula weight × (1 + reps / 30) when reps is greater than 1',
        () {
      expect(
        estimatedOneRepMax(effectiveWeight: 100, reps: 5),
        closeTo(100 * (1 + 5 / 30), 1e-9),
      );
    });

    test('AC-005: isNewPR is true only when the candidate one-rep max strictly exceeds the previous best',
        () {
      expect(isNewPR(candidateOneRepMax: 101, bestOneRepMax: 100), isTrue);
      expect(isNewPR(candidateOneRepMax: 100, bestOneRepMax: 100), isFalse);
      expect(isNewPR(candidateOneRepMax: 50, bestOneRepMax: 0), isTrue);
    });

    test('AC-006: formatWeight returns "BW" for a bodyweight set with zero added weight',
        () {
      expect(formatWeight(0, isBodyweight: true), 'BW');
    });

    test('AC-007: formatWeight returns "BW+10kg" and "BW-10kg" for bodyweight sets with added or removed weight',
        () {
      expect(formatWeight(10, isBodyweight: true), 'BW+10kg');
      expect(formatWeight(-10, isBodyweight: true), 'BW-10kg');
    });

    test('AC-008: formatWeight returns "75kg" for a normal weighted set', () {
      expect(formatWeight(75), '75kg');
    });

    test('AC-009: formatVolume groups thousands and appends " kg"', () {
      expect(formatVolume(4230), '4,230 kg');
    });
  });
}
