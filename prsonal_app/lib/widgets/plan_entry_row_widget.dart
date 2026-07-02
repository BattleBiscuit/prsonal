import 'package:flutter/material.dart';
import 'package:prsonal_app/theme/app_colors.dart';
import 'package:prsonal_app/theme/app_spacing.dart';

class PlanEntryRow extends StatelessWidget {
  const PlanEntryRow({
    super.key,
    required this.dayLabel,
    required this.routineName,
    this.done = false,
    this.startDisabled = false,
    this.onStart,
    this.onOpen,
  });

  final String dayLabel;
  final String routineName;
  final bool done;
  final bool startDisabled;
  final VoidCallback? onStart;

  /// Tapped the routine name to open the routine editor.
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: space2, horizontal: 4),
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
          const SizedBox(width: space3),
          Expanded(
            child: Semantics(
              label: 'Edit $routineName',
              button: true,
              container: true,
              onTap: onOpen,
              child: ExcludeSemantics(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onOpen,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          routineName,
                          style: TextStyle(
                            color: colors.text1,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.edit_outlined, color: colors.text2, size: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (done) ...[
            Semantics(
              label: 'Completed this week',
              container: true,
              child: ExcludeSemantics(
                child: Icon(
                  Icons.check_circle_outline,
                  color: colors.success,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: space2),
          ],
          Tooltip(
            message: 'Start $routineName',
            child: Semantics(
              label: 'Start $routineName',
              button: true,
              container: true,
              enabled: !startDisabled,
              child: GestureDetector(
                onTap: startDisabled ? null : onStart,
                child: Opacity(
                  opacity: startDisabled ? 0.4 : 1.0,
                  child: Padding(
                    padding: const EdgeInsets.all(space2),
                    child: Icon(
                      Icons.play_arrow_outlined,
                      color: done ? colors.text2 : colors.accent,
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
