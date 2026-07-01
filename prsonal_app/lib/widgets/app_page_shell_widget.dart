import 'package:flutter/material.dart';
import 'package:prsonal_app/theme/app_colors.dart';
import 'package:prsonal_app/widgets/brand_mark.dart';
import 'package:prsonal_app/theme/app_spacing.dart';

class AppPageShell extends StatelessWidget {
  const AppPageShell({
    super.key,
    required this.child,
    this.header,
    this.showWorkoutBanner = false,
    this.workoutRoutineName,
    this.onResumeWorkout,
  });

  final Widget child;
  final Widget? header;
  final bool showWorkoutBanner;
  final String? workoutRoutineName;
  final VoidCallback? onResumeWorkout;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top bar with PRsonal brand wordmark
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: space4,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Semantics(
                    label: 'PRsonal',
                    child: ExcludeSemantics(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          BrandMark(size: 22, color: colors.text1),
                          const SizedBox(width: space2),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'PR',
                                  style: TextStyle(color: colors.text1),
                                ),
                                TextSpan(
                                  text: 'sonal',
                                  style: TextStyle(color: colors.accent),
                                ),
                              ],
                            ),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (header != null) ...[
                    const SizedBox(width: space3),
                    Expanded(child: header!),
                  ],
                ],
              ),
            ),
            // Workout in progress banner
            if (showWorkoutBanner)
              GestureDetector(
                onTap: onResumeWorkout,
                child: Container(
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.08),
                    border: Border.all(
                      color: colors.accent.withValues(alpha: 0.20),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: space4,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.fitness_center_outlined,
                        color: colors.accent,
                        size: 16,
                      ),
                      const SizedBox(width: space2),
                      Text(
                        'Workout in progress',
                        style: TextStyle(
                          color: colors.accent,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (workoutRoutineName != null) ...[
                        const SizedBox(width: space2),
                        Text(
                          workoutRoutineName!,
                          style: TextStyle(color: colors.text2, fontSize: 14),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            // Body
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}
