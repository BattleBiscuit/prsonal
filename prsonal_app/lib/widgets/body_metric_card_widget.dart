import 'package:flutter/material.dart';
import 'package:prsonal_app/theme/app_colors.dart';
import 'package:prsonal_app/theme/app_typography.dart';
import 'package:prsonal_app/theme/app_spacing.dart';

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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: colors.accent, size: 20),
                const SizedBox(width: space2),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: colors.text2,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(Icons.edit_outlined, color: colors.text2, size: 18),
              ],
            ),
            const SizedBox(height: space3),
            Text(
              valueLabel,
              style: monoNumerals(
                TextStyle(
                  color: colors.text1,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (dateLabel != null) ...[
              const SizedBox(height: space1),
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
