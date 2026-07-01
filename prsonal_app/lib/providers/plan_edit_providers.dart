import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One entry being edited on the plan editor — a routine assigned to an
/// optional day of the week, before it's persisted as a [PlanEntryInput].
class PlanEntryDraftRow {
  PlanEntryDraftRow({
    required this.routineId,
    required this.routineName,
    this.dayOfWeek,
  });

  final String routineId;
  final String routineName;
  int? dayOfWeek;
}

/// The entry list being edited — business state for the plan editor, not
/// ephemeral UI state, so it lives in a Notifier rather than screen
/// `setState`. Scoped to the route via the `planId` family key (null = create
/// mode) so each editor instance gets independent, auto-disposed state.
class PlanEditorNotifier
    extends AutoDisposeFamilyNotifier<List<PlanEntryDraftRow>, String?> {
  @override
  List<PlanEntryDraftRow> build(String? planId) => [];

  /// Populates the editor from a loaded draft.
  void loadInitial(List<PlanEntryDraftRow> entries) {
    state = entries;
  }

  void addEntry(PlanEntryDraftRow entry) {
    state = [...state, entry];
  }

  void removeAt(int index) {
    state = [...state]..removeAt(index);
  }

  void setDayOfWeek(int index, int? dayOfWeek) {
    // Entries carry a mutable `dayOfWeek` field, but rows are still replaced
    // on the outer list so watchers relying on list identity see the change.
    state[index].dayOfWeek = dayOfWeek;
    state = [...state];
  }
}

final planEditorProvider = NotifierProvider.autoDispose
    .family<PlanEditorNotifier, List<PlanEntryDraftRow>, String?>(
      PlanEditorNotifier.new,
    );
