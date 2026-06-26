import 'package:flutter/material.dart';
import 'package:prsonal_app/models/exercise.dart';
import 'package:prsonal_app/theme/app_colors.dart';
import 'package:prsonal_app/widgets/exercise_search_input_widget.dart';

class SetFormData {
  SetFormData({
    this.reps = 0,
    this.weight = 0,
    this.isBodyweight = false,
  });

  int reps;
  double weight;
  bool isBodyweight;
}

class ExerciseFormData {
  const ExerciseFormData({
    this.exerciseId,
    this.exerciseName,
    required this.type,
    this.notes,
    required this.sets,
  });

  final String? exerciseId;
  final String? exerciseName;
  final ExerciseType type;
  final String? notes;
  final List<SetFormData> sets;
}

class ExerciseForm extends StatefulWidget {
  const ExerciseForm({
    super.key,
    this.initial,
    required this.exercises,
    required this.onSubmit,
    required this.onCancel,
  });

  final ExerciseFormData? initial;
  final List<ExerciseOption> exercises;
  final void Function(ExerciseFormData) onSubmit;
  final VoidCallback onCancel;

  @override
  State<ExerciseForm> createState() => _ExerciseFormState();
}

class _ExerciseFormState extends State<ExerciseForm> {
  String? _exerciseId;
  String? _exerciseName;
  ExerciseType _type = ExerciseType.strength;
  List<SetFormData> _sets = [];
  bool _showValidation = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    if (initial != null) {
      _exerciseId = initial.exerciseId;
      _exerciseName = initial.exerciseName;
      _type = initial.type;
      _sets = initial.sets.isNotEmpty
          ? initial.sets.map((s) => SetFormData(reps: s.reps, weight: s.weight, isBodyweight: s.isBodyweight)).toList()
          : [SetFormData()];
    } else {
      _sets = [SetFormData()];
    }
  }

  void _addSet() => setState(() => _sets.add(SetFormData()));

  void _removeSet(int i) {
    if (_sets.length <= 1) return;
    setState(() => _sets.removeAt(i));
  }

  void _submit() {
    if (_exerciseId == null && _exerciseName == null) {
      setState(() => _showValidation = true);
      return;
    }
    widget.onSubmit(ExerciseFormData(
      exerciseId: _exerciseId,
      exerciseName: _exerciseName,
      type: _type,
      sets: List.unmodifiable(_sets),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ExerciseSearchInput(
          exercises: widget.exercises,
          selectedName: _exerciseName,
          onSelected: (opt) => setState(() {
            _exerciseId = opt.id;
            _exerciseName = opt.name;
            _type = opt.type;
            _showValidation = false;
          }),
        ),
        if (_showValidation)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('Select an exercise', style: TextStyle(color: colors.danger, fontSize: 12)),
          ),
        const SizedBox(height: 12),
        ..._sets.asMap().entries.map((entry) {
          final i = entry.key;
          final set = entry.value;
          return _SetRow(
            key: ValueKey(i),
            set: set,
            canRemove: _sets.length > 1,
            onRemove: () => _removeSet(i),
            onToggleBw: () => setState(() => set.isBodyweight = !set.isBodyweight),
          );
        }),
        TextButton(
          onPressed: _addSet,
          child: Text('Add set', style: TextStyle(color: colors.accent)),
        ),
        const SizedBox(height: 16),
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
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({
    super.key,
    required this.set,
    required this.canRemove,
    required this.onRemove,
    required this.onToggleBw,
  });

  final SetFormData set;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback onToggleBw;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // BW toggle
          GestureDetector(
            onTap: onToggleBw,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: set.isBodyweight ? colors.accent : colors.surface2,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'BW',
                style: TextStyle(
                  color: set.isBodyweight ? colors.onAccent : colors.text2,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Reps',
                hintStyle: TextStyle(color: colors.text3),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              style: TextStyle(color: colors.text1),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'kg',
                hintStyle: TextStyle(color: colors.text3),
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              style: TextStyle(color: colors.text1),
            ),
          ),
          // Remove button - always shown but disabled (inert) when can't remove
          Semantics(
            label: 'Remove set',
            button: true,
            child: GestureDetector(
              onTap: canRemove ? onRemove : null,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.remove_circle_outline, color: canRemove ? colors.danger : colors.text3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
