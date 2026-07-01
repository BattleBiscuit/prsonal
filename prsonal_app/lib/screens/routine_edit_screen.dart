import 'dart:async';

import 'package:flutter/material.dart';
import '../widgets/brand_title.dart';
import '../widgets/app_modal_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exercise.dart';
import '../models/routine_exercise.dart';
import '../providers/app_providers.dart';
import '../services/routines_service.dart';
import '../theme/app_colors.dart';
import '../widgets/exercise_form_widget.dart';
import '../widgets/exercise_search_input_widget.dart';

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
  bool _dirty = false;
  bool _initialized = false;

  // Mutable exercise list (mirrors the draft)
  List<RoutineExerciseDraft> _exercises = [];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _markDirty() {
    if (!_dirty) setState(() => _dirty = true);
  }

  /// Called by the test: if dirty show a discard dialog, otherwise pop.
  Future<void> maybePop() async {
    if (!_dirty) {
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
              setState(() {
                _dirty = true;
                if (existing != null) {
                  final idx = _exercises.indexOf(existing);
                  if (idx >= 0) {
                    _exercises[idx] = RoutineExerciseDraft(
                      id: existing.id,
                      exerciseId: data.exerciseId ?? existing.exerciseId,
                      exerciseName: data.exerciseName ?? existing.exerciseName,
                      position: existing.position,
                      sets: data.sets
                          .map(
                            (s) => SetTarget.strength(
                              reps: s.reps,
                              weight: s.weight,
                              isBodyweight: s.isBodyweight,
                            ),
                          )
                          .toList(),
                      notes: existing.notes,
                    );
                  }
                } else {
                  _exercises.add(
                    RoutineExerciseDraft(
                      id: UniqueKey().toString(),
                      exerciseId: data.exerciseId ?? '',
                      exerciseName: data.exerciseName ?? '',
                      position: _exercises.length,
                      sets: data.sets
                          .map(
                            (s) => SetTarget.strength(
                              reps: s.reps,
                              weight: s.weight,
                              isBodyweight: s.isBodyweight,
                            ),
                          )
                          .toList(),
                      notes: null,
                    ),
                  );
                }
              });
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
      for (final ex in _exercises) {
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

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;
    final optionsAsync = ref.watch(libraryOptionsProvider);
    final options = optionsAsync.valueOrNull ?? const [];

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
            setState(() => _exercises = List.from(draft.exercises));
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
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: 'Routine name',
              errorText: _nameError ? 'Name is required' : null,
            ),
            onChanged: (_) {
              _markDirty();
              if (_nameError) setState(() => _nameError = false);
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesCtrl,
            decoration: const InputDecoration(labelText: 'Notes (optional)'),
            onChanged: (_) => _markDirty(),
          ),
          const SizedBox(height: 20),
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
          const SizedBox(height: 8),
          if (_exercises.isEmpty)
            Text(
              'No exercises yet',
              style: TextStyle(color: colors.text2, fontSize: 14),
            )
          else
            ReorderableListView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              onReorderItem: (oldIndex, newIndex) {
                setState(() {
                  _dirty = true;
                  final item = _exercises.removeAt(oldIndex);
                  _exercises.insert(newIndex, item);
                });
              },
              children: [
                for (final ex in _exercises)
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
                    trailing: const Icon(Icons.drag_handle),
                    onTap: () =>
                        _showExerciseForm(existing: ex, options: options),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
