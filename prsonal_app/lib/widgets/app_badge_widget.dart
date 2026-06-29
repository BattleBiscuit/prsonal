import 'package:flutter/material.dart';
import 'package:prsonal_app/theme/app_colors.dart';
import 'package:prsonal_app/theme/app_spacing.dart';

enum AppBadgeVariant { neutral, success, danger, warning, accent }

class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.neutral,
  });

  final String label;
  final AppBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;

    Color backgroundColor;
    Color textColor;

    switch (variant) {
      case AppBadgeVariant.neutral:
        backgroundColor = colors.surface3;
        textColor = colors.text2;
        break;
      case AppBadgeVariant.success:
        backgroundColor = colors.success.withValues(alpha: 0.20);
        textColor = colors.success;
        break;
      case AppBadgeVariant.danger:
        backgroundColor = colors.danger.withValues(alpha: 0.20);
        textColor = colors.danger;
        break;
      case AppBadgeVariant.warning:
        backgroundColor = colors.warning.withValues(alpha: 0.20);
        textColor = colors.warning;
        break;
      case AppBadgeVariant.accent:
        backgroundColor = colors.accent.withValues(alpha: 0.15);
        textColor = colors.accent;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radiusFull),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 12.0,
          fontWeight: FontWeight.w500,
        ),
        overflow: TextOverflow.clip,
        softWrap: false,
      ),
    );
  }
}
