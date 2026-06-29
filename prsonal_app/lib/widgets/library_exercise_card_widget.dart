import 'package:flutter/material.dart';
import 'package:prsonal_app/models/exercise.dart';
import 'package:prsonal_app/theme/app_colors.dart';

class LibraryExerciseCard extends StatelessWidget {
  const LibraryExerciseCard({
    super.key,
    required this.name,
    required this.type,
    required this.musclesLabel,
    this.prLabel,
    required this.onTap,
    required this.onDelete,
  });

  final String name;
  final ExerciseType type;
  final String musclesLabel;
  final String? prLabel;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
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
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surface3,
                          borderRadius: BorderRadius.zero,
                        ),
                        child: Text(
                          type.name,
                          style: TextStyle(
                            color: colors.text2,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        musclesLabel,
                        style: TextStyle(color: colors.text2, fontSize: 12),
                      ),
                    ],
                  ),
                  if (prLabel != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      prLabel!,
                      style: TextStyle(
                        color: colors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Semantics(
              label: 'Delete exercise',
              button: true,
              child: GestureDetector(
                onTap: onDelete,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(Icons.delete_outline, color: colors.text3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
