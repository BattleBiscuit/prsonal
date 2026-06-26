import 'package:flutter/material.dart';
import 'package:prsonal_app/theme/app_colors.dart';

class PlanEntryRow extends StatelessWidget {
  const PlanEntryRow({
    super.key,
    required this.dayLabel,
    required this.routineName,
    this.done = false,
    this.startDisabled = false,
    this.onStart,
  });

  final String dayLabel;
  final String routineName;
  final bool done;
  final bool startDisabled;
  final VoidCallback? onStart;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              dayLabel,
              style: TextStyle(
                color: colors.text2,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              routineName,
              style: TextStyle(
                color: colors.text1,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (done) ...[
            Semantics(
              label: 'Completed this week',
              container: true,
              child: ExcludeSemantics(
                child: Icon(Icons.check_circle,
                    color: colors.success, size: 20),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Semantics(
            label: 'Start $routineName',
            button: true,
            container: true,
            enabled: !startDisabled,
            onTap: startDisabled ? null : onStart,
            child: ExcludeSemantics(
              child: GestureDetector(
                onTap: startDisabled ? null : onStart,
                child: Opacity(
                  opacity: startDisabled ? 0.4 : 1.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: done ? colors.surface2 : colors.accent,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Start',
                      style: TextStyle(
                        color: done ? colors.text2 : colors.onAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
