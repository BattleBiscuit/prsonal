import 'package:flutter/material.dart';
import 'package:prsonal_app/theme/app_colors.dart';

class SessionProgressBar extends StatelessWidget {
  const SessionProgressBar({
    super.key,
    required this.progress,
  });

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
        borderRadius: BorderRadius.circular(3),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: clamped,
          child: Container(
            decoration: BoxDecoration(
              color: colors.accent,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        ),
      ),
    );
  }
}
