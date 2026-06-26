import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../models/body_metric.dart';
import '../models/exercise.dart';
import '../models/routine_exercise.dart';
import '../models/workout_math.dart';
import '../models/workout_session.dart';
import '../providers/app_providers.dart';
import 'platform_service.dart';

// ---------------------------------------------------------------------------
// Supporting enums / value objects
// ---------------------------------------------------------------------------

enum ActiveSetStatus { upcoming, pending, active, completed, skipped }

class ActiveSet {
  ActiveSet({
    required this.index,
    required this.kind,
    required this.plannedLabel,
    this.status = ActiveSetStatus.pending,
    this.actualLabel,
    this.isPR = false,
    // Internal fields — set by engine, not the UI test factories
    this.dbId,
    this.restSeconds = 0,
    this.plannedReps,
    this.plannedWeight,
    this.isBodyweight = false,
  });

  /// The index of this set within its exercise (0-based).
  final int index;
  final ExerciseType kind;
  final String plannedLabel;
  final ActiveSetStatus status;
  final String? actualLabel;
  final bool isPR;

  // Internal engine fields
  final String? dbId;
  final int restSeconds;
  final int? plannedReps;
  final double? plannedWeight;
  final bool isBodyweight;

  ActiveSet copyWith({
    ActiveSetStatus? status,
    String? actualLabel,
    bool? isPR,
    String? dbId,
  }) {
    return ActiveSet(
      index: index,
      kind: kind,
      plannedLabel: plannedLabel,
      status: status ?? this.status,
      actualLabel: actualLabel ?? this.actualLabel,
      isPR: isPR ?? this.isPR,
      dbId: dbId ?? this.dbId,
      restSeconds: restSeconds,
      plannedReps: plannedReps,
      plannedWeight: plannedWeight,
      isBodyweight: isBodyweight,
    );
  }
}

class ActiveExercise {
  ActiveExercise({
    required this.name,
    required this.sets,
    this.isCurrent = false,
    this.exerciseId,
    this.routineExerciseId,
    this.position = 0,
  });

  /// Test factory that constructs an [ActiveExercise] with minimal fields.
  factory ActiveExercise.forTest({
    required String name,
    required bool isCurrent,
    required List<ActiveSet> sets,
  }) {
    return ActiveExercise(name: name, sets: sets, isCurrent: isCurrent);
  }

  final String name;
  final List<ActiveSet> sets;
  final bool isCurrent;

  // Internal engine fields
  final String? exerciseId;
  final String? routineExerciseId;
  final int position;

  ActiveExercise copyWith({List<ActiveSet>? sets, bool? isCurrent}) {
    return ActiveExercise(
      name: name,
      sets: sets ?? this.sets,
      isCurrent: isCurrent ?? this.isCurrent,
      exerciseId: exerciseId,
      routineExerciseId: routineExerciseId,
      position: position,
    );
  }
}

// Record type for cursor position.
typedef SessionCursor = ({int exerciseIndex, int setIndex});

class ActiveSessionState {
  ActiveSessionState({
    required this.session,
    required this.exercises,
    required this.cursor,
    this.elapsed = Duration.zero,
    this.resting = false,
    this.restRemaining = 0,
    this.restTotal = 0,
  });

  /// Test factory — constructs state without a real DB session.
  factory ActiveSessionState.forTest({
    required String routineName,
    required Duration elapsed,
    required double progress,
    required bool isLastSet,
    required bool resting,
    required int restRemaining,
    required List<ActiveExercise> exercises,
  }) {
    // Build a synthetic session row.
    final session = WorkoutSession(
      id: 'test-session',
      routineId: 'test-routine',
      routineName: routineName,
      startedAt: DateTime.now(),
      completedAt: null,
      status: SessionStatus.active,
      planId: null,
      planEntryId: null,
    );
    // Compute cursor from exercises: find the first active/pending set.
    int exIdx = 0;
    int sIdx = 0;
    outer:
    for (var ei = 0; ei < exercises.length; ei++) {
      for (var si = 0; si < exercises[ei].sets.length; si++) {
        final s = exercises[ei].sets[si];
        if (s.status == ActiveSetStatus.active ||
            s.status == ActiveSetStatus.pending) {
          exIdx = ei;
          sIdx = si;
          break outer;
        }
      }
    }
    return _ActiveSessionStateForTest(
      session: session,
      exercises: exercises,
      cursor: (exerciseIndex: exIdx, setIndex: sIdx),
      elapsed: elapsed,
      resting: resting,
      restRemaining: restRemaining,
      overrideProgress: progress,
      overrideIsLastSet: isLastSet,
    );
  }

  final WorkoutSession session;
  final List<ActiveExercise> exercises;
  final SessionCursor cursor;
  final Duration elapsed;
  final bool resting;
  final int restRemaining;
  final int restTotal;

  // Derived getters

  int get totalCount => exercises.fold(0, (sum, e) => sum + e.sets.length);

  int get completedCount => exercises.fold(
    0,
    (sum, e) =>
        sum +
        e.sets
            .where(
              (s) =>
                  s.status == ActiveSetStatus.completed ||
                  s.status == ActiveSetStatus.skipped,
            )
            .length,
  );

  double get progress {
    final total = totalCount;
    if (total == 0) return 0.0;
    return completedCount / total;
  }

  bool get isLastSet {
    // The current set is last when there are no further pending/active sets
    // after it.
    bool foundCurrent = false;
    for (var ei = 0; ei < exercises.length; ei++) {
      final ex = exercises[ei];
      for (var si = 0; si < ex.sets.length; si++) {
        final s = ex.sets[si];
        if (ei == cursor.exerciseIndex && si == cursor.setIndex) {
          foundCurrent = true;
          continue;
        }
        if (foundCurrent &&
            (s.status == ActiveSetStatus.pending ||
                s.status == ActiveSetStatus.active)) {
          return false;
        }
      }
    }
    return foundCurrent;
  }

  ActiveSet? get currentSet {
    if (cursor.exerciseIndex >= exercises.length) return null;
    final ex = exercises[cursor.exerciseIndex];
    if (cursor.setIndex >= ex.sets.length) return null;
    return ex.sets[cursor.setIndex];
  }
}

/// Internal subclass used by [ActiveSessionState.forTest] to override computed
/// getters with the values supplied by the test.
class _ActiveSessionStateForTest extends ActiveSessionState {
  _ActiveSessionStateForTest({
    required super.session,
    required super.exercises,
    required super.cursor,
    required super.elapsed,
    required super.resting,
    required super.restRemaining,
    required this.overrideProgress,
    required this.overrideIsLastSet,
  });

  final double overrideProgress;
  final bool overrideIsLastSet;

  @override
  double get progress => overrideProgress;

  @override
  bool get isLastSet => overrideIsLastSet;
}

// ---------------------------------------------------------------------------
// SessionEngine — Riverpod Notifier
// ---------------------------------------------------------------------------

class SessionEngine extends Notifier<ActiveSessionState?> {
  static final _uuid = Uuid();
  static String _newId() => _uuid.v4();

  // Rest timer
  Timer? _restTimer;

  @override
  ActiveSessionState? build() => null;

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  AppDatabase get _db => ref.read(appDatabaseProvider);
  PlatformService get _platform => ref.read(platformServiceProvider);

  void _requireActive() {
    if (state == null) {
      throw StateError('No active session.');
    }
  }

  // -------------------------------------------------------------------------
  // reset — simulates an app restart (used by tests)
  // -------------------------------------------------------------------------

  void reset() {
    _restTimer?.cancel();
    _restTimer = null;
    state = null;
  }

  // -------------------------------------------------------------------------
  // startSession
  // -------------------------------------------------------------------------

  Future<void> startSession({
    required String routineId,
    String? planId,
    String? planEntryId,
  }) async {
    final routine = await _db.routineById(routineId);
    if (routine == null) {
      throw ArgumentError('Routine $routineId not found.');
    }
    final routineExerciseRows = await _db.routineExercisesForRoutine(routineId);
    if (routineExerciseRows.isEmpty) {
      throw ArgumentError('Routine $routineId has no exercises.');
    }

    final sessionId = _newId();
    final now = ref.read(nowProvider)();

    await _db.insertWorkoutSessionRow(
      WorkoutSessionsCompanion.insert(
        id: sessionId,
        routineId: routineId,
        routineName: routine.name,
        startedAt: now,
        status: SessionStatus.active,
        planId: Value(planId),
        planEntryId: Value(planEntryId),
      ),
    );

    final exercises = <ActiveExercise>[];

    for (final re in routineExerciseRows) {
      final exerciseRow = await _db.exerciseById(re.exerciseId);
      final exerciseName = exerciseRow?.name ?? re.exerciseId;
      final exerciseSets = <ActiveSet>[];
      for (var si = 0; si < re.sets.length; si++) {
        final target = re.sets[si];
        final setId = _newId();
        final label = _plannedLabel(target);

        await _db.insertWorkoutSetRow(
          WorkoutSetsCompanion.insert(
            id: setId,
            sessionId: sessionId,
            exercisePosition: re.position,
            exerciseId: Value(re.exerciseId),
            exerciseName: exerciseName,
            setIndex: si,
            type: target.kind,
            plannedReps: Value(target.reps),
            plannedWeight: Value(target.weight),
            isBodyweight: Value(target.isBodyweight ?? false),
            restSeconds: Value(target.restSeconds ?? 0),
          ),
        );

        exerciseSets.add(
          ActiveSet(
            index: si,
            kind: target.kind,
            plannedLabel: label,
            status: si == 0 && re.position == routineExerciseRows.first.position
                ? ActiveSetStatus.active
                : ActiveSetStatus.pending,
            dbId: setId,
            restSeconds: target.restSeconds ?? 0,
            plannedReps: target.reps,
            plannedWeight: target.weight,
            isBodyweight: target.isBodyweight ?? false,
          ),
        );
      }

      exercises.add(
        ActiveExercise(
          name: exerciseName,
          sets: exerciseSets,
          isCurrent: re.position == routineExerciseRows.first.position,
          exerciseId: re.exerciseId,
          routineExerciseId: re.id,
          position: re.position,
        ),
      );
    }

    final session = await _db.sessionById(sessionId);
    state = ActiveSessionState(
      session: session!,
      exercises: exercises,
      cursor: (exerciseIndex: 0, setIndex: 0),
    );

    await _platform.enableSessionWakelock();
  }

  // -------------------------------------------------------------------------
  // resumeActiveSession
  // -------------------------------------------------------------------------

  Future<bool> resumeActiveSession() async {
    final session = await _db.activeSession();
    if (session == null) return false;

    final sets = await _db.workoutSetsForSession(session.id);
    if (sets.isEmpty) return false;

    // Group sets by exercisePosition.
    final byPosition = <int, List<WorkoutSet>>{};
    for (final s in sets) {
      byPosition.putIfAbsent(s.exercisePosition, () => []).add(s);
    }

    final sortedPositions = byPosition.keys.toList()..sort();
    final exercises = <ActiveExercise>[];

    for (final pos in sortedPositions) {
      final positionSets = byPosition[pos]!
        ..sort((a, b) => a.setIndex.compareTo(b.setIndex));
      final first = positionSets.first;
      final activeSets = positionSets.map((ws) {
        ActiveSetStatus status;
        if (ws.completedAt != null) {
          status = ActiveSetStatus.completed;
        } else if (ws.skipped) {
          status = ActiveSetStatus.skipped;
        } else {
          status = ActiveSetStatus.pending;
        }
        return ActiveSet(
          index: ws.setIndex,
          kind: ws.type,
          plannedLabel: _plannedLabelFromSet(ws),
          status: status,
          actualLabel: status == ActiveSetStatus.completed
              ? _actualLabel(ws)
              : null,
          isPR: ws.isPR,
          dbId: ws.id,
          restSeconds: ws.restSeconds,
          plannedReps: ws.plannedReps,
          plannedWeight: ws.plannedWeight,
          isBodyweight: ws.isBodyweight,
        );
      }).toList();

      final exerciseRow = first.exerciseId != null
          ? await _db.exerciseById(first.exerciseId!)
          : null;

      exercises.add(
        ActiveExercise(
          name: exerciseRow?.name ?? first.exerciseName,
          sets: activeSets,
          exerciseId: first.exerciseId,
          position: pos,
        ),
      );
    }

    // Find cursor: first incomplete (pending) set.
    SessionCursor cursor = (exerciseIndex: 0, setIndex: 0);
    outer:
    for (var ei = 0; ei < exercises.length; ei++) {
      for (var si = 0; si < exercises[ei].sets.length; si++) {
        final s = exercises[ei].sets[si];
        if (s.status == ActiveSetStatus.pending) {
          cursor = (exerciseIndex: ei, setIndex: si);
          break outer;
        }
      }
    }

    // Mark current as active.
    final updatedExercises = _markCursorActive(exercises, cursor);

    state = ActiveSessionState(
      session: session,
      exercises: updatedExercises,
      cursor: cursor,
    );

    await _platform.enableSessionWakelock();
    return true;
  }

  // -------------------------------------------------------------------------
  // markCurrentSetComplete
  // -------------------------------------------------------------------------

  Future<bool> markCurrentSetComplete({
    required num actualPrimary,
    required num actualSecondary,
    required bool isBodyweight,
  }) {
    _requireActive();
    return _doMarkCurrentSetComplete(
      actualPrimary: actualPrimary,
      actualSecondary: actualSecondary,
      isBodyweight: isBodyweight,
    );
  }

  Future<bool> _doMarkCurrentSetComplete({
    required num actualPrimary,
    required num actualSecondary,
    required bool isBodyweight,
  }) async {
    final current = state!;
    final cursor = current.cursor;
    final currentSet =
        current.exercises[cursor.exerciseIndex].sets[cursor.setIndex];

    // Resolve bodyweight.
    final bodyweightMetric = await _db.latestBodyMetric(BodyMetricType.weight);
    final bodyweight = bodyweightMetric?.value ?? 80.0;

    // For strength sets compute effectiveWeight and 1RM.
    double? effectiveWeight;
    double? estimated1RM;
    bool isPR = false;

    if (currentSet.kind == ExerciseType.strength) {
      effectiveWeight = resolveEffectiveWeight(
        isBodyweight: isBodyweight,
        actualWeight: actualSecondary.toDouble(),
        bodyweight: bodyweight,
      );
      estimated1RM = estimatedOneRepMax(
        effectiveWeight: effectiveWeight,
        reps: actualPrimary.toInt(),
      );

      // PR detection: compare against max 1RM of all prior completed
      // strength sets for the same exercise (across all sessions and
      // earlier sets in this session).
      final exercise = current.exercises[cursor.exerciseIndex];
      final bestPrior = await _db.bestEstimated1RMForExercise(
        exerciseId: exercise.exerciseId,
        exerciseName: exercise.name,
        excludeSessionId: null,
        beforeSetId: currentSet.dbId,
        currentSessionId: current.session.id,
      );
      isPR = isNewPR(
        candidateOneRepMax: estimated1RM,
        bestOneRepMax: bestPrior,
      );
    }

    final now = ref.read(nowProvider)();
    final actualLabel = currentSet.kind == ExerciseType.strength
        ? '${actualPrimary.toInt()}×${_formatWeight(actualSecondary.toDouble(), isBodyweight: isBodyweight)}'
        : '${actualPrimary}s';

    // Update DB row.
    if (currentSet.dbId != null) {
      await _db.updateWorkoutSetRow(
        WorkoutSetsCompanion(
          id: Value(currentSet.dbId!),
          sessionId: Value(current.session.id),
          exercisePosition: Value(
            current.exercises[cursor.exerciseIndex].position,
          ),
          exerciseName: Value(current.exercises[cursor.exerciseIndex].name),
          setIndex: Value(currentSet.index),
          type: Value(currentSet.kind),
          actualReps: Value(actualPrimary.toInt()),
          actualWeight: Value(actualSecondary.toDouble()),
          effectiveWeight: Value(effectiveWeight),
          estimated1RM: Value(estimated1RM),
          completedAt: Value(now),
          isPR: Value(isPR),
          skipped: const Value(false),
        ),
      );
    }

    // Haptic feedback.
    if (isPR) {
      await _platform.hapticPR();
    } else {
      await _platform.hapticTap();
    }

    // Update in-memory state.
    final updatedSet = currentSet.copyWith(
      status: ActiveSetStatus.completed,
      actualLabel: actualLabel,
      isPR: isPR,
    );

    var updatedExercises = _updateSet(current.exercises, cursor, updatedSet);

    // Advance cursor.
    final nextCursor = _nextPendingCursor(updatedExercises, cursor);
    updatedExercises = _markCursorActive(updatedExercises, nextCursor);

    state = ActiveSessionState(
      session: current.session,
      exercises: updatedExercises,
      cursor: nextCursor,
      elapsed: current.elapsed,
    );

    // Start rest if applicable.
    if (currentSet.restSeconds > 0 && nextCursor != cursor) {
      startRest(currentSet.restSeconds);
    }

    return isPR;
  }

  // -------------------------------------------------------------------------
  // skipCurrentSet
  // -------------------------------------------------------------------------

  Future<void> skipCurrentSet() async {
    _requireActive();
    final current = state!;
    final cursor = current.cursor;
    final currentSet =
        current.exercises[cursor.exerciseIndex].sets[cursor.setIndex];

    if (currentSet.dbId != null) {
      await _db.updateWorkoutSetRow(
        WorkoutSetsCompanion(
          id: Value(currentSet.dbId!),
          sessionId: Value(current.session.id),
          exercisePosition: Value(
            current.exercises[cursor.exerciseIndex].position,
          ),
          exerciseName: Value(current.exercises[cursor.exerciseIndex].name),
          setIndex: Value(currentSet.index),
          type: Value(currentSet.kind),
          skipped: const Value(true),
        ),
      );
    }

    final updatedSet = currentSet.copyWith(status: ActiveSetStatus.skipped);
    var updatedExercises = _updateSet(current.exercises, cursor, updatedSet);
    final nextCursor = _nextPendingCursor(updatedExercises, cursor);
    updatedExercises = _markCursorActive(updatedExercises, nextCursor);

    state = ActiveSessionState(
      session: current.session,
      exercises: updatedExercises,
      cursor: nextCursor,
      elapsed: current.elapsed,
    );
  }

  // -------------------------------------------------------------------------
  // jumpToSet
  // -------------------------------------------------------------------------

  void jumpToSet(int exerciseIndex, int setIndex) {
    _requireActive();
    cancelRest();
    final current = state!;
    final newCursor = (exerciseIndex: exerciseIndex, setIndex: setIndex);
    final updatedExercises = _markCursorActive(current.exercises, newCursor);
    state = ActiveSessionState(
      session: current.session,
      exercises: updatedExercises,
      cursor: newCursor,
      elapsed: current.elapsed,
    );
  }

  // -------------------------------------------------------------------------
  // uncheckSet
  // -------------------------------------------------------------------------

  Future<void> uncheckSet(int exerciseIndex, int setIndex) async {
    _requireActive();
    final current = state!;
    final set = current.exercises[exerciseIndex].sets[setIndex];

    if (set.dbId != null) {
      await _db.updateWorkoutSetRow(
        WorkoutSetsCompanion(
          id: Value(set.dbId!),
          sessionId: Value(current.session.id),
          exercisePosition: Value(current.exercises[exerciseIndex].position),
          exerciseName: Value(current.exercises[exerciseIndex].name),
          setIndex: Value(set.index),
          type: Value(set.kind),
          actualReps: const Value(null),
          actualWeight: const Value(null),
          effectiveWeight: const Value(null),
          estimated1RM: const Value(null),
          completedAt: const Value(null),
          skipped: const Value(false),
          isPR: const Value(false),
        ),
      );
    }

    final clearedSet = ActiveSet(
      index: set.index,
      kind: set.kind,
      plannedLabel: set.plannedLabel,
      status: ActiveSetStatus.pending,
      dbId: set.dbId,
      restSeconds: set.restSeconds,
      plannedReps: set.plannedReps,
      plannedWeight: set.plannedWeight,
      isBodyweight: set.isBodyweight,
    );

    final newCursor = (exerciseIndex: exerciseIndex, setIndex: setIndex);
    cancelRest();
    var updatedExercises = _updateSet(current.exercises, newCursor, clearedSet);
    updatedExercises = _markCursorActive(updatedExercises, newCursor);

    state = ActiveSessionState(
      session: current.session,
      exercises: updatedExercises,
      cursor: newCursor,
      elapsed: current.elapsed,
    );
  }

  // -------------------------------------------------------------------------
  // addExerciseToSession
  // -------------------------------------------------------------------------

  Future<void> addExerciseToSession({
    required String exerciseId,
    required List<SetTarget> sets,
  }) async {
    _requireActive();
    final current = state!;
    final exerciseRow = await _db.exerciseById(exerciseId);
    final exerciseName = exerciseRow?.name ?? exerciseId;

    // Determine next position.
    final nextPosition = current.exercises.isEmpty
        ? 0
        : current.exercises
                  .map((e) => e.position)
                  .reduce((a, b) => a > b ? a : b) +
              1;

    final activeSets = <ActiveSet>[];
    for (var si = 0; si < sets.length; si++) {
      final target = sets[si];
      final setId = _newId();

      await _db.insertWorkoutSetRow(
        WorkoutSetsCompanion.insert(
          id: setId,
          sessionId: current.session.id,
          exercisePosition: nextPosition,
          exerciseId: Value(exerciseId),
          exerciseName: exerciseName,
          setIndex: si,
          type: target.kind,
          plannedReps: Value(target.reps),
          plannedWeight: Value(target.weight),
          isBodyweight: Value(target.isBodyweight ?? false),
          restSeconds: Value(target.restSeconds ?? 0),
        ),
      );

      activeSets.add(
        ActiveSet(
          index: si,
          kind: target.kind,
          plannedLabel: _plannedLabel(target),
          status: ActiveSetStatus.pending,
          dbId: setId,
          restSeconds: target.restSeconds ?? 0,
          plannedReps: target.reps,
          plannedWeight: target.weight,
          isBodyweight: target.isBodyweight ?? false,
        ),
      );
    }

    final newExercise = ActiveExercise(
      name: exerciseName,
      sets: activeSets,
      exerciseId: exerciseId,
      position: nextPosition,
    );

    state = ActiveSessionState(
      session: current.session,
      exercises: [...current.exercises, newExercise],
      cursor: current.cursor,
      elapsed: current.elapsed,
    );
  }

  // -------------------------------------------------------------------------
  // skipAllRemaining
  // -------------------------------------------------------------------------

  Future<void> skipAllRemaining() async {
    _requireActive();
    final current = state!;

    final updatedExercises = <ActiveExercise>[];
    for (final ex in current.exercises) {
      final updatedSets = <ActiveSet>[];
      for (final s in ex.sets) {
        if (s.status == ActiveSetStatus.pending ||
            s.status == ActiveSetStatus.active) {
          if (s.dbId != null) {
            await _db.updateWorkoutSetRow(
              WorkoutSetsCompanion(
                id: Value(s.dbId!),
                sessionId: Value(current.session.id),
                exercisePosition: Value(ex.position),
                exerciseName: Value(ex.name),
                setIndex: Value(s.index),
                type: Value(s.kind),
                skipped: const Value(true),
              ),
            );
          }
          updatedSets.add(s.copyWith(status: ActiveSetStatus.skipped));
        } else {
          updatedSets.add(s);
        }
      }
      updatedExercises.add(ex.copyWith(sets: updatedSets));
    }

    state = ActiveSessionState(
      session: current.session,
      exercises: updatedExercises,
      cursor: current.cursor,
      elapsed: current.elapsed,
    );
  }

  // -------------------------------------------------------------------------
  // finishSession
  // -------------------------------------------------------------------------

  Future<void> finishSession() async {
    _requireActive();
    final current = state!;
    cancelRest();

    final now = ref.read(nowProvider)();

    // Mark session completed.
    await _db.updateWorkoutSessionRow(
      WorkoutSessionsCompanion(
        id: Value(current.session.id),
        routineId: Value(current.session.routineId),
        routineName: Value(current.session.routineName),
        startedAt: Value(current.session.startedAt),
        completedAt: Value(now),
        status: Value(SessionStatus.completed),
      ),
    );

    // Write actuals back to routine as new planned targets.
    await _writeActualsToRoutine(current);

    await _platform.hapticSuccess();
    await _platform.disableSessionWakelock();

    state = null;
  }

  // -------------------------------------------------------------------------
  // abandonSession
  // -------------------------------------------------------------------------

  Future<void> abandonSession() async {
    _requireActive();
    final current = state!;
    cancelRest();

    await _db.deleteWorkoutSetsForSession(current.session.id);
    await _db.deleteWorkoutSessionById(current.session.id);

    await _platform.disableSessionWakelock();

    state = null;
  }

  // -------------------------------------------------------------------------
  // startRest / cancelRest
  // -------------------------------------------------------------------------

  void startRest(int seconds) {
    _restTimer?.cancel();
    _platform.scheduleRestComplete(Duration(seconds: seconds));

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state == null) {
        timer.cancel();
        return;
      }
      final remaining = state!.restRemaining - 1;
      if (remaining <= 0) {
        timer.cancel();
        state = ActiveSessionState(
          session: state!.session,
          exercises: state!.exercises,
          cursor: state!.cursor,
          elapsed: state!.elapsed,
          resting: false,
          restRemaining: 0,
          restTotal: state!.restTotal,
        );
      } else {
        state = ActiveSessionState(
          session: state!.session,
          exercises: state!.exercises,
          cursor: state!.cursor,
          elapsed: state!.elapsed,
          resting: true,
          restRemaining: remaining,
          restTotal: state!.restTotal,
        );
      }
    });

    // Set initial resting state immediately.
    if (state != null) {
      state = ActiveSessionState(
        session: state!.session,
        exercises: state!.exercises,
        cursor: state!.cursor,
        elapsed: state!.elapsed,
        resting: true,
        restRemaining: seconds,
        restTotal: seconds,
      );
    }
  }

  void cancelRest() {
    _restTimer?.cancel();
    _restTimer = null;
    _platform.cancelRestComplete();
    if (state != null) {
      state = ActiveSessionState(
        session: state!.session,
        exercises: state!.exercises,
        cursor: state!.cursor,
        elapsed: state!.elapsed,
        resting: false,
        restRemaining: 0,
        restTotal: 0,
      );
    }
  }

  // -------------------------------------------------------------------------
  // Private helpers
  // -------------------------------------------------------------------------

  Future<void> _writeActualsToRoutine(ActiveSessionState current) async {
    // Group sets by exercisePosition, then by setIndex.
    // For each routineExercise, update its sets field with actual reps/weight.
    final sets = await _db.workoutSetsForSession(current.session.id);
    if (sets.isEmpty) return;

    final byPosition = <int, List<WorkoutSet>>{};
    for (final s in sets) {
      byPosition.putIfAbsent(s.exercisePosition, () => []).add(s);
    }

    for (final ex in current.exercises) {
      if (ex.routineExerciseId == null) continue;
      final positionSets = byPosition[ex.position];
      if (positionSets == null) continue;

      positionSets.sort((a, b) => a.setIndex.compareTo(b.setIndex));

      final newTargets = positionSets.map((ws) {
        if (ws.type == ExerciseType.strength) {
          final reps = ws.actualReps ?? ws.plannedReps;
          final weight = ws.actualWeight ?? ws.plannedWeight ?? 0.0;
          return SetTarget.strength(
            reps: reps ?? 10,
            weight: weight,
            isBodyweight: ws.isBodyweight,
            restSeconds: ws.restSeconds,
          );
        } else {
          final duration = ws.actualDuration ?? ws.plannedDuration;
          final level = ws.actualLevel ?? ws.plannedLevel;
          return SetTarget.cardio(
            duration: duration ?? 20,
            level: level ?? 1,
            restSeconds: ws.restSeconds,
          );
        }
      }).toList();

      // Load current routine exercise to do a full replace.
      final routineExerciseRows = await _db.routineExercisesForRoutine(
        current.session.routineId,
      );
      for (final re in routineExerciseRows) {
        if (re.id == ex.routineExerciseId) {
          await _db.updateRoutineExerciseRow(
            RoutineExercisesCompanion(
              id: Value(re.id),
              routineId: Value(re.routineId),
              exerciseId: Value(re.exerciseId),
              position: Value(re.position),
              notes: Value(re.notes),
              sets: Value(newTargets),
            ),
          );
          break;
        }
      }
    }
  }

  List<ActiveExercise> _updateSet(
    List<ActiveExercise> exercises,
    SessionCursor cursor,
    ActiveSet updatedSet,
  ) {
    return exercises.asMap().entries.map((entry) {
      final ei = entry.key;
      final ex = entry.value;
      if (ei != cursor.exerciseIndex) return ex;
      final updatedSets = ex.sets.asMap().entries.map((se) {
        return se.key == cursor.setIndex ? updatedSet : se.value;
      }).toList();
      return ex.copyWith(sets: updatedSets);
    }).toList();
  }

  List<ActiveExercise> _markCursorActive(
    List<ActiveExercise> exercises,
    SessionCursor cursor,
  ) {
    return exercises.asMap().entries.map((entry) {
      final ei = entry.key;
      final ex = entry.value;
      final isCurrent = ei == cursor.exerciseIndex;
      final updatedSets = ex.sets.asMap().entries.map((se) {
        final si = se.key;
        final s = se.value;
        if (ei == cursor.exerciseIndex && si == cursor.setIndex) {
          if (s.status == ActiveSetStatus.pending) {
            return s.copyWith(status: ActiveSetStatus.active);
          }
        }
        return s;
      }).toList();
      return ex.copyWith(sets: updatedSets, isCurrent: isCurrent);
    }).toList();
  }

  /// Returns the next cursor pointing to the first pending set after [current].
  /// If none, stays at the current cursor.
  SessionCursor _nextPendingCursor(
    List<ActiveExercise> exercises,
    SessionCursor current,
  ) {
    // Look for the next pending set after the current position.
    for (var ei = 0; ei < exercises.length; ei++) {
      final ex = exercises[ei];
      for (var si = 0; si < ex.sets.length; si++) {
        // Skip sets up to and including the current one.
        if (ei < current.exerciseIndex) continue;
        if (ei == current.exerciseIndex && si <= current.setIndex) continue;
        if (ex.sets[si].status == ActiveSetStatus.pending) {
          return (exerciseIndex: ei, setIndex: si);
        }
      }
    }
    // No next pending set — keep cursor where it is.
    return current;
  }

  String _plannedLabel(SetTarget target) {
    if (target.kind == ExerciseType.strength) {
      final reps = target.reps ?? 0;
      final weight = target.weight ?? 0.0;
      final bw = target.isBodyweight ?? false;
      return '$reps×${_formatWeight(weight, isBodyweight: bw)}';
    } else {
      return '${target.duration ?? 0}s';
    }
  }

  String _plannedLabelFromSet(WorkoutSet ws) {
    if (ws.type == ExerciseType.strength) {
      final reps = ws.plannedReps ?? 0;
      final weight = ws.plannedWeight ?? 0.0;
      return '$reps×${_formatWeight(weight, isBodyweight: ws.isBodyweight)}';
    } else {
      return '${ws.plannedDuration ?? 0}s';
    }
  }

  String _actualLabel(WorkoutSet ws) {
    if (ws.type == ExerciseType.strength) {
      final reps = ws.actualReps ?? 0;
      final weight = ws.actualWeight ?? 0.0;
      return '$reps×${_formatWeight(weight, isBodyweight: ws.isBodyweight)}';
    } else {
      return '${ws.actualDuration ?? 0}s';
    }
  }

  String _formatWeight(double weight, {bool isBodyweight = false}) {
    if (isBodyweight) {
      if (weight == 0) return 'BW';
      return 'BW+${_numStr(weight)}kg';
    }
    return '${_numStr(weight)}kg';
  }

  String _numStr(double v) {
    if (v == v.truncateToDouble()) return v.truncate().toString();
    return v.toString();
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

final sessionEngineProvider =
    NotifierProvider<SessionEngine, ActiveSessionState?>(SessionEngine.new);
