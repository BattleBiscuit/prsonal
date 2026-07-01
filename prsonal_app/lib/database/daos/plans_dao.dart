import 'package:drift/drift.dart';

import '../app_database.dart';

/// Plan + plan-entry queries. Kept as extension methods on [AppDatabase]
/// (rather than a `@DriftAccessor` DAO class) so call sites keep the same
/// `db.method()` surface used throughout the app's services.
extension PlansDao on AppDatabase {
  /// Returns all plans ordered by their order field.
  Future<List<Plan>> allPlans() {
    return (select(plans)..orderBy([(p) => OrderingTerm.asc(p.order)])).get();
  }

  /// Returns a stream of all plans.
  Stream<List<Plan>> watchAllPlans() {
    return (select(plans)..orderBy([(p) => OrderingTerm.asc(p.order)])).watch();
  }

  /// Returns a single plan by id, or null.
  Future<Plan?> planById(String id) {
    return (select(plans)..where((p) => p.id.equals(id))).getSingleOrNull();
  }

  /// Inserts a plan row.
  Future<void> insertPlanRow(PlansCompanion row) => into(plans).insert(row);

  /// Updates a plan row.
  Future<bool> updatePlanRow(PlansCompanion row) => update(plans).replace(row);

  /// Deletes a plan by id.
  Future<int> deletePlanById(String id) =>
      (delete(plans)..where((p) => p.id.equals(id))).go();

  // ---------------------------------------------------------------------------
  // PlanEntry queries
  // ---------------------------------------------------------------------------

  /// Returns a stream that emits whenever any plan entry changes.
  Stream<List<PlanEntry>> watchAllPlanEntries() {
    return select(planEntries).watch();
  }

  /// Returns all entries for a plan in order.
  Future<List<PlanEntry>> planEntriesForPlan(String planId) {
    return (select(planEntries)
          ..where((pe) => pe.planId.equals(planId))
          ..orderBy([(pe) => OrderingTerm.asc(pe.order)]))
        .get();
  }

  /// Inserts a plan entry row.
  Future<void> insertPlanEntryRow(PlanEntriesCompanion row) =>
      into(planEntries).insert(row);

  /// Deletes all entries for a plan.
  Future<int> deletePlanEntriesForPlan(String planId) =>
      (delete(planEntries)..where((pe) => pe.planId.equals(planId))).go();

  // ---------------------------------------------------------------------------
  // Bulk export / import (used by BackupService)
  // ---------------------------------------------------------------------------

  Future<List<Plan>> allPlans2() => select(plans).get();
  Future<List<PlanEntry>> allPlanEntries() => select(planEntries).get();

  Future<void> clearPlans() => delete(plans).go();
  Future<void> clearPlanEntries() => delete(planEntries).go();

  Future<void> bulkInsertPlans(List<PlansCompanion> rows) async {
    await batch((b) => b.insertAll(plans, rows));
  }

  Future<void> bulkInsertPlanEntries(List<PlanEntriesCompanion> rows) async {
    await batch((b) => b.insertAll(planEntries, rows));
  }
}
