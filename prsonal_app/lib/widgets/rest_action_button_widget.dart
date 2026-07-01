import 'package:flutter/material.dart';
import 'package:prsonal_app/theme/app_colors.dart';
import 'package:prsonal_app/theme/app_spacing.dart';

class RestActionButton extends StatelessWidget {
  const RestActionButton({
    super.key,
    required this.resting,
    required this.label,
    required this.onPressed,
    this.remainingSeconds = 0,
  });

  final bool resting;
  final String label;
  final VoidCallback onPressed;
  final int remainingSeconds;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;

    final displayLabel = resting ? 'Rest ${remainingSeconds}s' : label;

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        constraints: const BoxConstraints(minHeight: touchTargetMin),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: resting ? colors.surface3 : colors.accent,
          borderRadius: BorderRadius.zero,
        ),
        child: Center(
          child: Text(
            displayLabel,
            style: TextStyle(
              color: resting ? colors.text2 : colors.onAccent,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
