import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/routines_service.dart';

export '../services/routines_service.dart' show RoutineExerciseDraft;

/// The exercise list being edited plus its unsaved-changes flag — business
/// state for the routine editor, not ephemeral UI state, so it lives in a
/// Notifier rather than screen `setState`.
class RoutineEditorState {
  const RoutineEditorState({this.exercises = const [], this.dirty = false});

  final List<RoutineExerciseDraft> exercises;
  final bool dirty;

  RoutineEditorState copyWith({
    List<RoutineExerciseDraft>? exercises,
    bool? dirty,
  }) {
    return RoutineEditorState(
      exercises: exercises ?? this.exercises,
      dirty: dirty ?? this.dirty,
    );
  }
}

/// Scoped to the route via the `routineId` family key (null = create mode) so
/// each editor instance gets independent, auto-disposed state.
class RoutineEditorNotifier
    extends AutoDisposeFamilyNotifier<RoutineEditorState, String?> {
  @override
  RoutineEditorState build(String? routineId) => const RoutineEditorState();

  /// Populates the editor from a loaded draft. Only called once, before the
  /// user has made any edits, so it does not itself mark the state dirty.
  void loadInitial(List<RoutineExerciseDraft> exercises) {
    state = RoutineEditorState(exercises: exercises);
  }

  void addExercise(RoutineExerciseDraft exercise) {
    state = state.copyWith(
      exercises: [...state.exercises, exercise],
      dirty: true,
    );
  }

  void replaceExercise(
    RoutineExerciseDraft existing,
    RoutineExerciseDraft updated,
  ) {
    final index = state.exercises.indexOf(existing);
    if (index < 0) return;
    final next = [...state.exercises];
    next[index] = updated;
    state = state.copyWith(exercises: next, dirty: true);
  }

  void reorder(int oldIndex, int newIndex) {
    final next = [...state.exercises];
    final item = next.removeAt(oldIndex);
    next.insert(newIndex, item);
    state = state.copyWith(exercises: next, dirty: true);
  }

  void markDirty() {
    if (!state.dirty) state = state.copyWith(dirty: true);
  }
}

final routineEditorProvider = NotifierProvider.autoDispose
    .family<RoutineEditorNotifier, RoutineEditorState, String?>(
      RoutineEditorNotifier.new,
    );
