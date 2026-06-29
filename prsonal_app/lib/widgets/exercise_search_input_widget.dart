import 'package:flutter/material.dart';
import 'package:prsonal_app/models/exercise.dart';
import 'package:prsonal_app/theme/app_colors.dart';

@immutable
class ExerciseOption {
  const ExerciseOption({
    required this.id,
    required this.name,
    required this.type,
    required this.primaryMuscles,
  });

  final String id;
  final String name;
  final ExerciseType type;
  final List<Muscle> primaryMuscles;
}

class ExerciseSearchInput extends StatelessWidget {
  const ExerciseSearchInput({
    super.key,
    required this.exercises,
    required this.onSelected,
    this.selectedName,
    this.onCreate,
  });

  final List<ExerciseOption> exercises;
  final void Function(ExerciseOption) onSelected;
  final String? selectedName;
  final void Function(String)? onCreate;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;
    return GestureDetector(
      onTap: () => _openSheet(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: colors.surface2,
          borderRadius: BorderRadius.zero,
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                selectedName ?? 'Select exercise',
                style: TextStyle(
                  color: selectedName != null ? colors.text1 : colors.text3,
                  fontSize: 15,
                ),
              ),
            ),
            Icon(Icons.search, color: colors.text3, size: 18),
          ],
        ),
      ),
    );
  }

  void _openSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _ExerciseSearchSheet(
        exercises: exercises,
        onSelected: (opt) {
          Navigator.of(ctx).pop();
          onSelected(opt);
        },
        onCreate: onCreate != null
            ? (q) {
                Navigator.of(ctx).pop();
                onCreate!(q);
              }
            : null,
      ),
    );
  }
}

class _ExerciseSearchSheet extends StatefulWidget {
  const _ExerciseSearchSheet({
    required this.exercises,
    required this.onSelected,
    this.onCreate,
  });

  final List<ExerciseOption> exercises;
  final void Function(ExerciseOption) onSelected;
  final void Function(String)? onCreate;

  @override
  State<_ExerciseSearchSheet> createState() => _ExerciseSearchSheetState();
}

class _ExerciseSearchSheetState extends State<_ExerciseSearchSheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;
    final filtered = widget.exercises
        .where((e) => e.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    final showCreate =
        _query.isNotEmpty && filtered.isEmpty && widget.onCreate != null;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search exercises',
                hintStyle: TextStyle(color: colors.text3),
                filled: true,
                fillColor: colors.surface2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: colors.text1),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              children: [
                ...filtered.map(
                  (opt) => ListTile(
                    title: Text(
                      opt.name,
                      style: TextStyle(color: colors.text1),
                    ),
                    onTap: () => widget.onSelected(opt),
                  ),
                ),
                if (showCreate)
                  ListTile(
                    title: Text(
                      'Create "$_query"',
                      style: TextStyle(color: colors.accent),
                    ),
                    onTap: () => widget.onCreate!(_query),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
