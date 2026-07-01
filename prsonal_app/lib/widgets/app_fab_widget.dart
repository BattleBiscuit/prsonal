import 'package:flutter/material.dart';
import 'package:prsonal_app/theme/app_colors.dart';
import 'package:prsonal_app/theme/app_spacing.dart';

class AppFab extends StatelessWidget {
  const AppFab({
    super.key,
    this.label,
    required this.icon,
    this.onPressed,
    this.tooltip,
  }) : assert(
         label != null || tooltip != null,
         'AppFab needs a label or a tooltip so the bare-icon form stays accessible.',
       );

  final String? label;
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;

    final Widget child = label != null
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            constraints: const BoxConstraints(minHeight: touchTargetMin),
            decoration: BoxDecoration(
              color: colors.accent,
              borderRadius: BorderRadius.circular(radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: colors.onAccent, size: 20),
                const SizedBox(width: space2),
                Text(
                  label!,
                  style: TextStyle(
                    color: colors.onAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          )
        : Container(
            width: touchTargetMin,
            height: touchTargetMin,
            decoration: BoxDecoration(
              color: colors.accent,
              borderRadius: BorderRadius.circular(radiusFull),
            ),
            child: Icon(icon, color: colors.onAccent, size: 20),
          );

    return Tooltip(
      message: tooltip ?? label!,
      child: Opacity(
        opacity: onPressed == null ? 0.4 : 1.0,
        child: GestureDetector(onTap: onPressed, child: child),
      ),
    );
  }
}
