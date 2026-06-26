// BodyMetric model — pure Dart, no Flutter/Drift imports.

enum BodyMetricType {
  weight,
  bodyfat,
  waist,
  chest,
  arms,
  legs;

  String get unit {
    switch (this) {
      case BodyMetricType.weight:
        return 'kg';
      case BodyMetricType.bodyfat:
        return '%';
      case BodyMetricType.waist:
      case BodyMetricType.chest:
      case BodyMetricType.arms:
      case BodyMetricType.legs:
        return 'cm';
    }
  }

  String get label {
    switch (this) {
      case BodyMetricType.weight:
        return 'Bodyweight';
      case BodyMetricType.bodyfat:
        return 'Body fat';
      case BodyMetricType.waist:
        return 'Waist';
      case BodyMetricType.chest:
        return 'Chest';
      case BodyMetricType.arms:
        return 'Arms';
      case BodyMetricType.legs:
        return 'Legs';
    }
  }
}

/// Pure data class representing a single logged body measurement.
class BodyMetric {
  const BodyMetric({
    required this.id,
    required this.type,
    required this.value,
    required this.loggedAt,
  });

  final String id;
  final BodyMetricType type;
  final double value;
  final DateTime loggedAt;
}

/// Returns true when [value] is strictly greater than zero.
bool validateBodyMetricValue(num value) => value > 0;
