import 'package:flutter/material.dart';
import 'package:prsonal_app/theme/app_colors.dart';

class BodyMetricCard extends StatelessWidget {
  const BodyMetricCard({
    super.key,
    required this.label,
    required this.valueLabel,
    this.dateLabel,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final String valueLabel;
  final String? dateLabel;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: colors.accent, size: 20),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: colors.text2,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              valueLabel,
              style: TextStyle(
                color: colors.text1,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (dateLabel != null) ...[
              const SizedBox(height: 4),
              Text(
                dateLabel!,
                style: TextStyle(color: colors.text3, fontSize: 12),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
