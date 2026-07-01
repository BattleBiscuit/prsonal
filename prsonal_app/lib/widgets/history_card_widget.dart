import 'package:flutter/material.dart';
import 'package:prsonal_app/theme/app_colors.dart';

class HistoryCard extends StatelessWidget {
  const HistoryCard({
    super.key,
    required this.routineName,
    required this.dateLabel,
    required this.metaLabel,
    this.abandoned = false,
    required this.onTap,
    required this.onDelete,
  });

  final String routineName;
  final String dateLabel;
  final String metaLabel;
  final bool abandoned;
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
                  Row(
                    children: [
                      Text(
                        routineName,
                        style: TextStyle(
                          color: colors.text1,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (abandoned) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: colors.danger.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.zero,
                          ),
                          child: Text(
                            'Abandoned',
                            style: TextStyle(
                              color: colors.danger,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateLabel,
                    style: TextStyle(color: colors.text2, fontSize: 13),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    metaLabel,
                    style: TextStyle(color: colors.text2, fontSize: 13),
                  ),
                ],
              ),
            ),
            Tooltip(
              message: 'Delete workout',
              child: Semantics(
                label: 'Delete workout',
                button: true,
                child: GestureDetector(
                  onTap: onDelete,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(Icons.delete_outline, color: colors.danger),
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
