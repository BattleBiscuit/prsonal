import 'package:drift/drift.dart';

// The Drift-generated row type is also named BodyMetric — hide the model's
// pure value type of the same name to avoid an ambiguous import.
import '../../models/body_metric.dart' hide BodyMetric;
import '../app_database.dart';

/// Body-metric queries. Kept as extension methods on [AppDatabase] (rather
/// than a `@DriftAccessor` DAO class) so call sites keep the same
/// `db.method()` surface used throughout the app's services.
extension BodyMetricsDao on AppDatabase {
  /// Returns a stream of body metrics for [type] ordered by loggedAt descending.
  Stream<List<BodyMetric>> watchBodyMetrics(BodyMetricType type) {
    return (select(bodyMetrics)
          ..where((b) => b.type.equals(type.name))
          ..orderBy([(b) => OrderingTerm.desc(b.loggedAt)]))
        .watch();
  }

  /// Returns the most recent body metric for [type], or null.
  Future<BodyMetric?> latestBodyMetric(BodyMetricType type) {
    return (select(bodyMetrics)
          ..where((b) => b.type.equals(type.name))
          ..orderBy([(b) => OrderingTerm.desc(b.loggedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Returns the most recent body metric for each type.
  Future<Map<BodyMetricType, BodyMetric>> latestBodyMetrics() async {
    final result = <BodyMetricType, BodyMetric>{};
    for (final type in BodyMetricType.values) {
      final row = await latestBodyMetric(type);
      if (row != null) result[type] = row;
    }
    return result;
  }

  /// Inserts a body metric row.
  Future<void> insertBodyMetricRow(BodyMetricsCompanion row) =>
      into(bodyMetrics).insert(row);

  /// Deletes a body metric by id.
  Future<int> deleteBodyMetricById(String id) =>
      (delete(bodyMetrics)..where((b) => b.id.equals(id))).go();

  // ---------------------------------------------------------------------------
  // Bulk export / import (used by BackupService)
  // ---------------------------------------------------------------------------

  Future<List<BodyMetric>> allBodyMetrics() => select(bodyMetrics).get();
  Future<void> clearBodyMetrics() => delete(bodyMetrics).go();

  Future<void> bulkInsertBodyMetrics(List<BodyMetricsCompanion> rows) async {
    await batch((b) => b.insertAll(bodyMetrics, rows));
  }
}
