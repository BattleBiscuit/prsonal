import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart' as db_lib;
import '../models/body_metric.dart';
import '../providers/app_providers.dart';

// ---------------------------------------------------------------------------
// BodyService
// ---------------------------------------------------------------------------

class BodyService {
  BodyService(this._db);

  final db_lib.AppDatabase _db;
  static final _uuid = Uuid();

  // -------------------------------------------------------------------------
  // watchLatest — most recent entry per metric type
  // -------------------------------------------------------------------------

  Stream<Map<BodyMetricType, BodyMetric?>> watchLatest() {
    // Watch all body metrics (using weight stream as the trigger for any
    // change), then re-query all types.
    return _db.watchBodyMetrics(BodyMetricType.weight).asyncMap((_) async {
      final result = <BodyMetricType, BodyMetric?>{};
      for (final type in BodyMetricType.values) {
        final row = await _db.latestBodyMetric(type);
        result[type] = row != null ? _toModel(row) : null;
      }
      return result;
    });
  }

  // -------------------------------------------------------------------------
  // watchHistory — entries for a type within optional window, newest first
  // -------------------------------------------------------------------------

  Stream<List<BodyMetric>> watchHistory(BodyMetricType? type, {int? days}) {
    if (type == null) return Stream.value([]);
    return _db.watchBodyMetrics(type).map((rows) {
      final models = rows.map(_toModel).toList();
      if (days == null) return models;
      final cutoff = DateTime.now().subtract(Duration(days: days));
      return models.where((m) => m.loggedAt.isAfter(cutoff)).toList();
    });
  }

  // -------------------------------------------------------------------------
  // log — inserts a metric
  // -------------------------------------------------------------------------

  Future<void> log(BodyMetricType? type, double value, {DateTime? at}) async {
    if (type == null) return;
    await _db.insertBodyMetricRow(
      db_lib.BodyMetricsCompanion.insert(
        id: _uuid.v4(),
        type: type,
        value: value,
        loggedAt: at ?? DateTime.now(),
      ),
    );
  }

  // -------------------------------------------------------------------------
  // deleteEntry — removes one entry
  // -------------------------------------------------------------------------

  Future<void> deleteEntry(String id) async {
    await _db.deleteBodyMetricById(id);
  }

  // -------------------------------------------------------------------------
  // currentBodyweight — latest weight, or 80 kg
  // -------------------------------------------------------------------------

  Future<double> currentBodyweight() async {
    final latest = await _db.latestBodyMetric(BodyMetricType.weight);
    return latest?.value ?? 80.0;
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  /// Maps a Drift row to the pure-model [BodyMetric].
  BodyMetric _toModel(db_lib.BodyMetric row) => BodyMetric(
    id: row.id,
    type: row.type,
    value: row.value,
    loggedAt: row.loggedAt,
  );
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final bodyServiceProvider = Provider<BodyService>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return BodyService(db);
});
