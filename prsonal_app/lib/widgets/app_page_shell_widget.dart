import 'package:flutter/material.dart';
import 'package:prsonal_app/theme/app_colors.dart';

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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Semantics(
                    label: 'PRsonal',
                    child: ExcludeSemantics(
                      child: Text(
                        'PRsonal',
                        style: TextStyle(
                          color: colors.accent,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                  if (header != null) ...[
                    const SizedBox(width: 12),
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
                  color: colors.accent.withValues(alpha: 0.15),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Icon(Icons.fitness_center,
                          color: colors.accent, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Workout in progress',
                        style: TextStyle(
                          color: colors.accent,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (workoutRoutineName != null) ...[
                        const SizedBox(width: 8),
                        Text(
                          workoutRoutineName!,
                          style: TextStyle(
                            color: colors.text2,
                            fontSize: 14,
                          ),
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
