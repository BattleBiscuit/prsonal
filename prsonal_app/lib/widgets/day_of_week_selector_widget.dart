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

    // Seven fixed touchTargetMin (48dp) circles don't fit inside the entry
    // row's padded container on narrow phones (overflows ~74px at 320dp
    // width) and visibly spill past the border. Each day instead gets an
    // equal share of the available width via Expanded, with height following
    // width via AspectRatio — always fits, whatever the screen.
    return Row(
      children: [
        for (var i = 0; i < _days.length; i++) ...[
          if (i > 0) const SizedBox(width: space1),
          Expanded(
            child: _DayChip(
              label: _days[i],
              isSelected: selected == i,
              onTap: () => onChanged(selected == i ? null : i),
              colors: colors,
            ),
          ),
        ],
      ],
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.colors,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? colors.accent : colors.surface2,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? colors.accent : colors.border,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? colors.onAccent : colors.text2,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
