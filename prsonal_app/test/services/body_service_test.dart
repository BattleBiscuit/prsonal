import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/database/app_database.dart';
import 'package:prsonal_app/models/body_metric.dart';
import 'package:prsonal_app/providers/app_providers.dart';
import 'package:prsonal_app/services/body_service.dart';

void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late BodyService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    service = container.read(bodyServiceProvider);
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  group('BodyService', () {
    test('AC-001: log inserts a metric of the given type and value', () async {
      await service.log(BodyMetricType.weight, 82.5, at: DateTime(2026, 6, 23));
      final history = await service.watchHistory(BodyMetricType.weight).first;
      expect(history.single.value, 82.5);
    });

    test(
      'AC-002: watchLatest returns the most recent entry for each metric type',
      () async {
        await service.log(
          BodyMetricType.weight,
          82.0,
          at: DateTime(2026, 6, 20),
        );
        await service.log(
          BodyMetricType.weight,
          81.5,
          at: DateTime(2026, 6, 23),
        );
        final latest = await service.watchLatest().first;
        expect(latest[BodyMetricType.weight]?.value, 81.5);
      },
    );

    test(
      'AC-003: watchHistory returns entries for a type within the window, newest first',
      () async {
        await service.log(BodyMetricType.waist, 88, at: DateTime(2026, 6, 20));
        await service.log(BodyMetricType.waist, 87, at: DateTime(2026, 6, 23));
        final history = await service.watchHistory(BodyMetricType.waist).first;
        expect(history.map((e) => e.value), [87, 88]);
      },
    );

    test('AC-003: watchHistory with a `days` window excludes entries older '
        'than that window', () async {
      final now = DateTime.now();
      await service.log(
        BodyMetricType.waist,
        90,
        at: now.subtract(const Duration(days: 100)), // outside a 90d window
      );
      await service.log(
        BodyMetricType.waist,
        85,
        at: now.subtract(const Duration(days: 10)), // inside it
      );
      final windowed = await service
          .watchHistory(BodyMetricType.waist, days: 90)
          .first;
      expect(windowed.map((e) => e.value), [85]);

      // No window → both entries, confirming the filter is opt-in.
      final unwindowed = await service.watchHistory(BodyMetricType.waist).first;
      expect(unwindowed.length, 2);
    });

    test('AC-004: deleteEntry removes a single entry', () async {
      await service.log(BodyMetricType.weight, 82.5, at: DateTime(2026, 6, 23));
      final id =
          (await service.watchHistory(BodyMetricType.weight).first).single.id;
      await service.deleteEntry(id);
      expect(await service.watchHistory(BodyMetricType.weight).first, isEmpty);
    });

    test(
      'AC-005: currentBodyweight returns the latest logged weight, or 80 when none exists',
      () async {
        expect(await service.currentBodyweight(), 80);
        await service.log(
          BodyMetricType.weight,
          78.0,
          at: DateTime(2026, 6, 23),
        );
        expect(await service.currentBodyweight(), 78.0);
      },
    );
  });
}
