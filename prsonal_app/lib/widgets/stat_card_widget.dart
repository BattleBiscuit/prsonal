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

    // Graphite is monochrome: tone no longer maps to a hue. The value's own
    // sign ("+8%" / "-5%") carries up/down; the icon stays chalk.
    final Color toneColor = colors.accent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) Icon(icon, color: toneColor, size: 16),
          if (icon != null) const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: colors.text1,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: colors.text2,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
