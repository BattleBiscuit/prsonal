import 'package:flutter/material.dart';
import 'package:prsonal_app/theme/app_colors.dart';

class ExerciseListItem extends StatelessWidget {
  const ExerciseListItem({
    super.key,
    required this.name,
    required this.setsSummary,
    required this.onTap,
    required this.onDelete,
  });

  final String name;
  final String setsSummary;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: colors.surface1,
          border: Border(bottom: BorderSide(color: colors.border)),
        ),
        child: Row(
          children: [
            Tooltip(
              message: 'Reorder exercise',
              child: Semantics(
                label: 'Reorder exercise',
                container: true,
                child: Padding(
                  padding: const EdgeInsets.all(4.0),
                  child: Icon(Icons.drag_handle, size: 20, color: colors.text3),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: colors.text1,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    setsSummary,
                    style: TextStyle(color: colors.text2, fontSize: 13),
                  ),
                ],
              ),
            ),
            Tooltip(
              message: 'Remove exercise',
              child: Semantics(
                label: 'Remove exercise',
                button: true,
                child: GestureDetector(
                  onTap: onDelete,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.close, color: colors.text3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
