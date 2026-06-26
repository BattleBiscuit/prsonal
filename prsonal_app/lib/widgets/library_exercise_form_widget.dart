import 'package:flutter/material.dart';
import 'package:prsonal_app/models/exercise.dart';
import 'package:prsonal_app/theme/app_colors.dart';

class LibraryExerciseData {
  const LibraryExerciseData({
    this.id,
    required this.name,
    required this.type,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    this.notes,
  });

  final String? id;
  final String name;
  final ExerciseType type;
  final List<Muscle> primaryMuscles;
  final List<Muscle> secondaryMuscles;
  final String? notes;
}

class LibraryExerciseForm extends StatefulWidget {
  const LibraryExerciseForm({
    super.key,
    this.initial,
    required this.onSubmit,
    required this.onCancel,
  });

  final LibraryExerciseData? initial;
  final void Function(LibraryExerciseData) onSubmit;
  final VoidCallback onCancel;

  @override
  State<LibraryExerciseForm> createState() => _LibraryExerciseFormState();
}

class _LibraryExerciseFormState extends State<LibraryExerciseForm> {
  final _nameCtrl = TextEditingController();
  ExerciseType _type = ExerciseType.strength;
  final Set<Muscle> _primary = {};
  final Set<Muscle> _secondary = {};
  bool _showValidation = false;

  @override
  void initState() {
    super.initState();
    final init = widget.initial;
    if (init != null) {
      _nameCtrl.text = init.name;
      _type = init.type;
      _primary.addAll(init.primaryMuscles);
      _secondary.addAll(init.secondaryMuscles);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _showValidation = true);
      return;
    }
    widget.onSubmit(
      LibraryExerciseData(
        id: widget.initial?.id,
        name: _nameCtrl.text.trim(),
        type: _type,
        primaryMuscles: _primary.toList(),
        secondaryMuscles: _secondary.toList(),
        notes: null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: 'Exercise name',
              labelStyle: TextStyle(color: colors.text2),
              errorText: _showValidation && _nameCtrl.text.trim().isEmpty
                  ? 'Name is required'
                  : null,
            ),
            style: TextStyle(color: colors.text1),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _TypeChip(
                label: 'Strength',
                selected: _type == ExerciseType.strength,
                onTap: () => setState(() => _type = ExerciseType.strength),
                colors: colors,
              ),
              const SizedBox(width: 8),
              _TypeChip(
                label: 'Cardio',
                selected: _type == ExerciseType.cardio,
                onTap: () => setState(() => _type = ExerciseType.cardio),
                colors: colors,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Primary muscles',
            style: TextStyle(
              color: colors.text2,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: Muscle.values
                .map(
                  (m) => _MuscleChip(
                    label: m.label,
                    selected: _primary.contains(m),
                    onTap: () => setState(() {
                      if (_primary.contains(m)) {
                        _primary.remove(m);
                      } else {
                        _primary.add(m);
                      }
                    }),
                    colors: colors,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 16),
          Text(
            'Secondary muscles',
            style: TextStyle(
              color: colors.text2,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: Muscle.values
                .map(
                  (m) => _MuscleChip(
                    label: m.label,
                    selected: _secondary.contains(m),
                    onTap: () => setState(() {
                      if (_secondary.contains(m)) {
                        _secondary.remove(m);
                      } else {
                        _secondary.add(m);
                      }
                    }),
                    colors: colors,
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancel,
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.colors,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? colors.accent : colors.surface2,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? colors.onAccent : colors.text2,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _MuscleChip extends StatelessWidget {
  const _MuscleChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.colors,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected
              ? colors.accentDim.withValues(alpha: 0.2)
              : colors.surface2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? colors.accent : colors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? colors.accent : colors.text2,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
