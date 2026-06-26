import 'package:flutter/material.dart';
import 'package:prsonal_app/theme/app_colors.dart';

enum AppButtonVariant { primary, ghost, danger, accent }

enum AppButtonSize { md, sm }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.md,
    this.full = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final AppButtonSize size;
  final bool full;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;

    final double minHeight = size == AppButtonSize.md ? 48.0 : 36.0;
    final EdgeInsets padding = size == AppButtonSize.md
        ? const EdgeInsets.symmetric(horizontal: 20.0)
        : const EdgeInsets.symmetric(horizontal: 12.0);

    Color backgroundColor;
    Color textColor;
    Color? borderColor;

    switch (variant) {
      case AppButtonVariant.primary:
        backgroundColor = colors.surface2;
        textColor = colors.text1;
        borderColor = colors.border;
        break;
      case AppButtonVariant.accent:
        backgroundColor = colors.accent;
        textColor = colors.onAccent;
        borderColor = null;
        break;
      case AppButtonVariant.ghost:
        backgroundColor = Colors.transparent;
        textColor = colors.text2;
        borderColor = colors.border;
        break;
      case AppButtonVariant.danger:
        backgroundColor = Colors.transparent;
        textColor = colors.danger;
        borderColor = colors.danger;
        break;
    }

    Widget content = Row(
      mainAxisSize: full ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          icon!,
          const SizedBox(width: 8),
        ],
        Text(
          label,
          style: TextStyle(
            color: textColor,
            fontSize: size == AppButtonSize.md ? 16.0 : 14.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );

    Widget button = GestureDetector(
      onTap: onPressed,
      child: Container(
        constraints: BoxConstraints(minHeight: minHeight),
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
          border: borderColor != null ? Border.all(color: borderColor) : null,
        ),
        child: content,
      ),
    );

    if (full) {
      button = SizedBox(width: double.infinity, child: button);
    }

    return Opacity(
      opacity: onPressed == null ? 0.4 : 1.0,
      child: button,
    );
  }
}
