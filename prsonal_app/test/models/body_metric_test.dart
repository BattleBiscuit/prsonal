import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/models/body_metric.dart';

void main() {
  group('BodyMetric', () {
    test('AC-001: BodyMetricType exposes exactly six types: weight, bodyfat, waist, chest, arms, legs',
        () {
      expect(BodyMetricType.values, [
        BodyMetricType.weight,
        BodyMetricType.bodyfat,
        BodyMetricType.waist,
        BodyMetricType.chest,
        BodyMetricType.arms,
        BodyMetricType.legs,
      ]);
    });

    test('AC-002: BodyMetricType.unit returns "kg" for weight, "%" for bodyfat, and "cm" for waist, chest, arms and legs',
        () {
      expect(BodyMetricType.weight.unit, 'kg');
      expect(BodyMetricType.bodyfat.unit, '%');
      for (final t in [
        BodyMetricType.waist,
        BodyMetricType.chest,
        BodyMetricType.arms,
        BodyMetricType.legs,
      ]) {
        expect(t.unit, 'cm');
      }
    });

    test('AC-003: BodyMetricType.label returns the display label (Bodyweight, Body fat, Waist, Chest, Arms, Legs)',
        () {
      expect(BodyMetricType.weight.label, 'Bodyweight');
      expect(BodyMetricType.bodyfat.label, 'Body fat');
      expect(BodyMetricType.waist.label, 'Waist');
      expect(BodyMetricType.chest.label, 'Chest');
      expect(BodyMetricType.arms.label, 'Arms');
      expect(BodyMetricType.legs.label, 'Legs');
    });

    test('AC-004: validateBodyMetricValue returns false for a value of zero or less and true for a positive value',
        () {
      expect(validateBodyMetricValue(0), isFalse);
      expect(validateBodyMetricValue(-1), isFalse);
      expect(validateBodyMetricValue(82.5), isTrue);
    });

    test('AC-005: BodyMetricType resolves from its stored name; an unknown name throws',
        () {
      expect(BodyMetricType.values.byName('waist'), BodyMetricType.waist);
      expect(() => BodyMetricType.values.byName('height'), throwsArgumentError);
    });
  });
}
