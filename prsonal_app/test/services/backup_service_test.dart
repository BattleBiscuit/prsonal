import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/database/app_database.dart';
import 'package:prsonal_app/models/exercise.dart';
import 'package:prsonal_app/providers/app_providers.dart';
import 'package:prsonal_app/services/backup_service.dart';

BackupService _serviceFor(AppDatabase db) =>
    ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)])
        .read(backupServiceProvider);

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('BackupService', () {
    test('AC-001: exportJson serializes the selected sections to a JSON document', () async {
      await db.insertExercise(name: 'Bench', type: ExerciseType.strength);
      final json = await _serviceFor(db).exportJson(sections: {BackupSection.library});
      expect(json, contains('Bench'));
    });

    test('AC-002: importJson replaces the selected sections with the document\'s contents',
        () async {
      await db.insertExercise(name: 'Bench', type: ExerciseType.strength);
      final json = await _serviceFor(db).exportJson(sections: {BackupSection.library});

      final db2 = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db2.close);
      await _serviceFor(db2).importJson(json, sections: {BackupSection.library});
      final counts = await _serviceFor(db2).counts();
      expect(counts[BackupSection.library], 1);
    });

    test('AC-003: an export followed by an import into an empty database reproduces the data',
        () async {
      await db.insertExercise(name: 'Bench', type: ExerciseType.strength);
      await db.insertRoutine(name: 'Push Day A');
      final all = {BackupSection.library, BackupSection.routines};
      final json = await _serviceFor(db).exportJson(sections: all);

      final db2 = AppDatabase.forTesting(NativeDatabase.memory());
      addTearDown(db2.close);
      final svc2 = _serviceFor(db2);
      await svc2.importJson(json, sections: all);
      final counts = await svc2.counts();
      expect(counts[BackupSection.library], 1);
      expect(counts[BackupSection.routines], 1);
    });

    test('AC-004: counts returns the number of records available per section', () async {
      await db.insertExercise(name: 'Bench', type: ExerciseType.strength);
      await db.insertExercise(name: 'Squat', type: ExerciseType.strength);
      final counts = await _serviceFor(db).counts();
      expect(counts[BackupSection.library], 2);
    });

    test('AC-005: importJson throws a FormatException for malformed input', () async {
      expect(
        () => _serviceFor(db).importJson('not json', sections: {BackupSection.library}),
        throwsFormatException,
      );
    });
  });
}
