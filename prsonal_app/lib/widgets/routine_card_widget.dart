import 'package:flutter/material.dart';
import 'package:prsonal_app/theme/app_colors.dart';

class RoutineCard extends StatelessWidget {
  const RoutineCard({
    super.key,
    required this.name,
    required this.metaLine,
    this.notes,
    required this.onTap,
    required this.onDelete,
  });

  final String name;
  final String metaLine;
  final String? notes;
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    metaLine,
                    style: TextStyle(color: colors.text2, fontSize: 13),
                  ),
                  if (notes != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      notes!,
                      style: TextStyle(color: colors.text3, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            Semantics(
              label: 'Delete routine',
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
