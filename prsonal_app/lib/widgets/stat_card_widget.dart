import 'package:flutter/material.dart';
import 'package:prsonal_app/theme/app_colors.dart';

enum StatTone { neutral, success, danger, warning }

class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.icon,
    this.tone = StatTone.neutral,
  });

  final String value;
  final String label;
  final IconData? icon;
  final StatTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;

    Color toneColor;
    switch (tone) {
      case StatTone.success:
        toneColor = colors.success;
      case StatTone.danger:
        toneColor = colors.danger;
      case StatTone.warning:
        toneColor = colors.warning;
      case StatTone.neutral:
        toneColor = colors.accent;
    }

    return Container(
      decoration: BoxDecoration(
        color: colors.surface1,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Icon(icon, color: toneColor, size: 16),
          if (icon != null) const SizedBox(height: 4),
          Text(value, style: TextStyle(color: colors.text1, fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: colors.text2, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
