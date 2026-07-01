import 'package:flutter/material.dart';
import 'package:prsonal_app/theme/app_colors.dart';
import 'package:prsonal_app/theme/app_motion.dart';

class SessionProgressBar extends StatelessWidget {
  const SessionProgressBar({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;
    final clamped = progress.clamp(0.0, 1.0);

    return Container(
      height: 6,
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.surface3,
        borderRadius: BorderRadius.zero,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: TweenAnimationBuilder<double>(
          duration: AppDurations.slow,
          curve: Curves.easeOut,
          tween: Tween(begin: 0.0, end: clamped),
          builder: (context, value, child) => FractionallySizedBox(
            widthFactor: value,
            child: Container(
              decoration: BoxDecoration(
                color: colors.accent,
                borderRadius: BorderRadius.zero,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
