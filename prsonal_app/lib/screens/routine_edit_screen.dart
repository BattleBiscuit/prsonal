import 'dart:async';

import 'package:flutter/material.dart';
import '../widgets/app_button_widget.dart';
import '../widgets/brand_title.dart';
import '../widgets/app_modal_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exercise.dart';
import '../models/routine_exercise.dart';
import '../providers/app_providers.dart';
import '../providers/routine_edit_providers.dart';
import '../services/routines_service.dart';
import '../theme/app_colors.dart';
import '../widgets/exercise_form_widget.dart';
import '../widgets/exercise_search_input_widget.dart';
import 'package:prsonal_app/theme/app_spacing.dart';

class RoutineEditScreen extends ConsumerStatefulWidget {
  const RoutineEditScreen({super.key, this.routineId});

  final String? routineId;

  @override
  ConsumerState<RoutineEditScreen> createState() => _RoutineEditScreenState();
}

class _RoutineEditScreenState extends ConsumerState<RoutineEditScreen> {
  final _nameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _nameError = false;
  bool _initialized = false;

  RoutineEditorNotifier get _editor =>
      ref.read(routineEditorProvider(widget.routineId).notifier);

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  /// Called by the test: if dirty show a discard dialog, otherwise pop.
  Future<void> maybePop() async {
    final dirty = ref.read(routineEditorProvider(widget.routineId)).dirty;
    if (!dirty) {
      if (mounted) unawaited(Navigator.of(context).maybePop());
      return;
    }
    // Fire the sheet but do NOT await it — the caller pumps frames so the sheet
    // appears and then asserts on its content.
    unawaited(
      showConfirmSheet(
        context,
        title: 'Discard changes?',
        confirmLabel: 'Discard',
        cancelLabel: 'Keep editing',
      ).then((discard) {
        if (discard && mounted) Navigator.of(context).maybePop();
      }),
    );
  }

  void _showExerciseForm({
    RoutineExerciseDraft? existing,
    List<ExerciseOption> options = const [],
  }) {
    ExerciseFormData? initial;
    if (existing != null) {
      initial = ExerciseFormData(
        exerciseId: existing.exerciseId,
        exerciseName: existing.exerciseName,
        type: existing.sets.isNotEmpty
            ? existing.sets.first.kind
            : ExerciseType.strength,
        sets: existing.sets
            .map((s) => SetFormData(reps: s.reps ?? 0, weight: s.weight ?? 0))
            .toList(),
      );
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: ExerciseForm(
            initial: initial,
            exercises: options,
            onSubmit: (data) {
              Navigator.of(ctx).pop();
              final sets = data.sets
                  .map(
                    (s) => SetTarget.strength(
                      reps: s.reps,
                      weight: s.weight,
                      isBodyweight: s.isBodyweight,
                    ),
                  )
                  .toList();
              if (existing != null) {
                _editor.replaceExercise(
                  existing,
                  RoutineExerciseDraft(
                    id: existing.id,
                    exerciseId: data.exerciseId ?? existing.exerciseId,
                    exerciseName: data.exerciseName ?? existing.exerciseName,
                    position: existing.position,
                    sets: sets,
                    notes: existing.notes,
                  ),
                );
              } else {
                final exerciseCount = ref
                    .read(routineEditorProvider(widget.routineId))
                    .exercises
                    .length;
                _editor.addExercise(
                  RoutineExerciseDraft(
                    id: UniqueKey().toString(),
                    exerciseId: data.exerciseId ?? '',
                    exerciseName: data.exerciseName ?? '',
                    position: exerciseCount,
                    sets: sets,
                    notes: null,
                  ),
                );
              }
            },
            onCancel: () => Navigator.of(ctx).pop(),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = true);
      return;
    }
    setState(() => _nameError = false);
    final service = ref.read(routinesServiceProvider);
    final routineId = widget.routineId;
    if (routineId == null) {
      final newId = await service.createRoutine(
        name: name,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      // Add exercises
      final exercises = ref
          .read(routineEditorProvider(widget.routineId))
          .exercises;
      for (final ex in exercises) {
        await service.addExercise(
          newId,
          exerciseId: ex.exerciseId,
          sets: ex.sets,
          notes: ex.notes,
        );
      }
    } else {
      await service.updateRoutine(
        routineId,
        name: name,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
    }
    if (mounted) await Navigator.of(context).maybePop();
  }

  Future<void> _delete() async {
    final routineId = widget.routineId;
    if (routineId == null) return;
    final confirmed = await showConfirmSheet(
      context,
      title: 'Delete routine?',
      message: 'This will remove the routine and its exercises.',
      confirmLabel: 'Delete',
      cancelLabel: 'Cancel',
    );
    if (!confirmed) return;
    final service = ref.read(routinesServiceProvider);
    await service.deleteRoutine(routineId);
    if (mounted) await Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;
    final optionsAsync = ref.watch(libraryOptionsProvider);
    final options = optionsAsync.valueOrNull ?? const [];

    final exercises = ref.watch(
      routineEditorProvider(widget.routineId).select((s) => s.exercises),
    );

    // Load draft in edit mode
    if (widget.routineId != null) {
      final draftAsync = ref.watch(routineDraftProvider(widget.routineId));
      if (!_initialized && draftAsync.hasValue && draftAsync.value != null) {
        final draft = draftAsync.value!;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_initialized) {
            _initialized = true;
            _nameCtrl.text = draft.name;
            _notesCtrl.text = draft.notes ?? '';
            _editor.loadInitial(List.from(draft.exercises));
          }
        });
      }
    } else {
      _initialized = true;
    }

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: BrandTitle(
          widget.routineId == null ? 'New Routine' : 'Edit Routine',
        ),
        backgroundColor: colors.bg,
        actions: [
          IconButton(
            onPressed: _save,
            icon: const Icon(Icons.check),
            tooltip: 'Save',
            color: colors.accent,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(space4),
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: 'Routine name',
              errorText: _nameError ? 'Name is required' : null,
            ),
            onChanged: (_) {
              _editor.markDirty();
              if (_nameError) setState(() => _nameError = false);
            },
          ),
          const SizedBox(height: space3),
          TextField(
            controller: _notesCtrl,
            decoration: const InputDecoration(labelText: 'Notes (optional)'),
            onChanged: (_) => _editor.markDirty(),
          ),
          const SizedBox(height: space5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Exercises',
                style: TextStyle(
                  color: colors.text1,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: () => _showExerciseForm(options: options),
                icon: const Icon(Icons.add),
                iconSize: 20,
                tooltip: 'Add exercise',
                color: colors.accent,
              ),
            ],
          ),
          const SizedBox(height: space2),
          if (exercises.isEmpty)
            Text(
              'No exercises yet',
              style: TextStyle(color: colors.text2, fontSize: 14),
            )
          else
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorderItem: _editor.reorder,
              children: [
                for (final ex in exercises)
                  ListTile(
                    key: ValueKey(ex.id),
                    title: Text(
                      ex.exerciseName,
                      style: TextStyle(color: colors.text1),
                    ),
                    subtitle: Text(
                      '${ex.sets.length} set${ex.sets.length == 1 ? '' : 's'}',
                      style: TextStyle(color: colors.text2, fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.edit_outlined, color: colors.text2),
                        const SizedBox(width: space2),
                        Icon(Icons.drag_handle, color: colors.text3, size: 20),
                      ],
                    ),
                    onTap: () =>
                        _showExerciseForm(existing: ex, options: options),
                  ),
              ],
            ),
          if (widget.routineId != null) ...[
            const SizedBox(height: space6),
            AppButton(
              label: 'Delete routine',
              variant: AppButtonVariant.danger,
              full: true,
              onPressed: _delete,
            ),
          ],
        ],
      ),
    );
  }
}
