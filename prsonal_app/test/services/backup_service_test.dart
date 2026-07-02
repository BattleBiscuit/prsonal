import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/database/app_database.dart';
import 'package:prsonal_app/models/exercise.dart';
import 'package:prsonal_app/providers/app_providers.dart';
import 'package:prsonal_app/services/backup_service.dart';

BackupService _serviceFor(AppDatabase db) => ProviderContainer(
  overrides: [appDatabaseProvider.overrideWithValue(db)],
).read(backupServiceProvider);

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('BackupService', () {
    test(
      'AC-001: exportJson serializes the selected sections to a JSON document',
      () async {
        await db.insertExercise(
          name: 'Bench',
          type: ExerciseType.strength,
          primaryMuscles: [Muscle.chest],
          notes: 'Pause at the bottom',
        );
        final json = await _serviceFor(
          db,
        ).exportJson(sections: {BackupSection.library});
        final doc = jsonDecode(json) as Map<String, dynamic>;
        final row = (doc['library'] as List).single as Map<String, dynamic>;
        // Every field, not just the name — a bug that dropped type/muscles/
        // notes during serialization would still pass a `contains('Bench')`
        // check.
        expect(row['name'], 'Bench');
        expect(row['type'], 'strength');
        expect(row['primaryMuscles'], ['chest']);
        expect(row['notes'], 'Pause at the bottom');
      },
    );

    test(
      'AC-002: importJson replaces the selected sections with the document\'s contents',
      () async {
        await db.insertExercise(
          name: 'Bench',
          type: ExerciseType.strength,
          primaryMuscles: [Muscle.chest],
        );
        final json = await _serviceFor(
          db,
        ).exportJson(sections: {BackupSection.library});

        // The target DB already has different library data — importing must
        // replace it, not merge with or append to it.
        final db2 = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(db2.close);
        await db2.insertExercise(name: 'Squat', type: ExerciseType.strength);
        await _serviceFor(
          db2,
        ).importJson(json, sections: {BackupSection.library});

        final exercises = await db2.allExercises();
        expect(exercises.map((e) => e.name), ['Bench']);
        expect(exercises.single.primaryMuscles, [Muscle.chest]);
      },
    );

    test(
      'AC-003: an export followed by an import into an empty database reproduces the data',
      () async {
        await db.insertExercise(
          name: 'Bench',
          type: ExerciseType.strength,
          primaryMuscles: [Muscle.chest],
          secondaryMuscles: [Muscle.arms],
          notes: 'Pause at the bottom',
        );
        await db.insertRoutine(name: 'Push Day A', notes: 'Heavy day');
        final all = {BackupSection.library, BackupSection.routines};
        final json = await _serviceFor(db).exportJson(sections: all);

        final db2 = AppDatabase.forTesting(NativeDatabase.memory());
        addTearDown(db2.close);
        final svc2 = _serviceFor(db2);
        await svc2.importJson(json, sections: all);

        final exercise = (await db2.allExercises()).single;
        expect(exercise.name, 'Bench');
        expect(exercise.type, ExerciseType.strength);
        expect(exercise.primaryMuscles, [Muscle.chest]);
        expect(exercise.secondaryMuscles, [Muscle.arms]);
        expect(exercise.notes, 'Pause at the bottom');

        final routine = (await db2.allRoutines()).single;
        expect(routine.name, 'Push Day A');
        expect(routine.notes, 'Heavy day');
      },
    );

    test(
      'AC-004: counts returns the number of records available per section',
      () async {
        await db.insertExercise(name: 'Bench', type: ExerciseType.strength);
        await db.insertExercise(name: 'Squat', type: ExerciseType.strength);
        final counts = await _serviceFor(db).counts();
        expect(counts[BackupSection.library], 2);
      },
    );

    test(
      'AC-005: importJson throws a FormatException for malformed input',
      () async {
        expect(
          () => _serviceFor(
            db,
          ).importJson('not json', sections: {BackupSection.library}),
          throwsFormatException,
        );
      },
    );
  });
}
