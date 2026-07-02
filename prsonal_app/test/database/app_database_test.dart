import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/database/app_database.dart';
import 'package:prsonal_app/models/exercise.dart';

void main() {
  group('AppDatabase', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(NativeDatabase.memory());
    });
    tearDown(() async {
      await db.close();
    });

    test('foreign key enforcement is on — SQLite has it off per-connection by '
        'default, so this is a canary for the `PRAGMA foreign_keys = ON` in '
        'the migration strategy. Without it, every declared cascade/restrict '
        'in the schema silently stops being enforced, exactly as it did '
        'before that pragma was added (deleted sessions/routines left their '
        'sets/exercises as permanently orphaned rows).', () async {
      // 'missing-session' does not exist — a real FK violation.
      await expectLater(
        db.insertWorkoutSetRow(
          WorkoutSetsCompanion.insert(
            id: 'set1',
            sessionId: 'missing-session',
            exercisePosition: 0,
            exerciseName: 'Bench',
            setIndex: 0,
            type: ExerciseType.strength,
          ),
        ),
        throwsA(anything),
      );
    });

    test('deleting a workout session cascades to its sets', () async {
      final sessionId = await db.seedCompletedSession(
        routineId: 'r1',
        startedAt: DateTime(2026, 6, 23),
        sets: [
          SeedSet(
            exercisePosition: 0,
            exerciseName: 'Bench',
            setIndex: 0,
            type: ExerciseType.strength,
            skipped: false,
            isPR: false,
          ),
        ],
      );
      expect(await db.workoutSetsForSession(sessionId), isNotEmpty);

      await db.deleteWorkoutSessionById(sessionId);

      expect(await db.workoutSetsForSession(sessionId), isEmpty);
    });
  });
}
