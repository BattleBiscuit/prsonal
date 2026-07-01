import 'package:flutter/material.dart';
import 'package:prsonal_app/theme/app_colors.dart';
import 'package:prsonal_app/theme/app_spacing.dart';

class DayOfWeekSelector extends StatelessWidget {
  const DayOfWeekSelector({super.key, this.selected, required this.onChanged});

  final int? selected;
  final ValueChanged<int?> onChanged;

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(_days.length, (i) {
        final isSelected = selected == i;
        return GestureDetector(
          onTap: () {
            if (isSelected) {
              onChanged(null);
            } else {
              onChanged(i);
            }
          },
          child: Container(
            width: touchTargetMin,
            height: touchTargetMin,
            decoration: BoxDecoration(
              color: isSelected ? colors.accent : colors.surface2,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? colors.accent : colors.border,
              ),
            ),
            child: Center(
              child: Text(
                _days[i],
                style: TextStyle(
                  color: isSelected ? colors.onAccent : colors.text2,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}
