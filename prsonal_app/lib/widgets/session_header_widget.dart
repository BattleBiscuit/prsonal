import 'package:flutter/material.dart';
import 'package:prsonal_app/theme/app_colors.dart';
import 'package:prsonal_app/theme/app_typography.dart';
import 'package:prsonal_app/widgets/live_dot_widget.dart';
import 'package:prsonal_app/theme/app_spacing.dart';

class SessionHeader extends StatelessWidget {
  const SessionHeader({
    super.key,
    required this.routineName,
    required this.elapsed,
    required this.onQuit,
    required this.onFinish,
  });

  final String routineName;
  final Duration elapsed;
  final VoidCallback onQuit;
  final VoidCallback onFinish;

  String _formatElapsed(Duration d) {
    if (d.inHours > 0) {
      final h = d.inHours;
      final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
      final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
      return '$h:$m:$s';
    } else {
      final m = d.inMinutes;
      final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
      return '$m:$s';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;

    return Row(
      children: [
        Tooltip(
          message: 'Quit workout',
          child: Semantics(
            label: 'Quit workout',
            button: true,
            child: GestureDetector(
              onTap: onQuit,
              child: Container(
                padding: const EdgeInsets.all(space2),
                child: Icon(Icons.close, color: colors.danger, size: 22),
              ),
            ),
          ),
        ),
        const SizedBox(width: space2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                routineName,
                style: TextStyle(
                  color: colors.text1,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const LiveDot(),
                  const SizedBox(width: 6),
                  Text(
                    _formatElapsed(elapsed),
                    style: monoNumerals(
                      TextStyle(color: colors.text3, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: space2),
        Tooltip(
          message: 'Finish workout',
          child: Semantics(
            label: 'Finish workout',
            button: true,
            child: GestureDetector(
              onTap: onFinish,
              child: Container(
                padding: const EdgeInsets.all(space2),
                child: Icon(Icons.check, color: colors.accent, size: 22),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
