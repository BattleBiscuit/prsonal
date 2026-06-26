import 'package:flutter/material.dart';
import 'package:prsonal_app/theme/app_colors.dart';

class WorkoutSummaryHeader extends StatelessWidget {
  const WorkoutSummaryHeader({
    super.key,
    required this.routineName,
    required this.dateTimeLabel,
    required this.durationLabel,
    required this.volumeLabel,
    required this.statusLabel,
  });

  final String routineName;
  final String dateTimeLabel;
  final String durationLabel;
  final String volumeLabel;
  final String statusLabel;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          dateTimeLabel,
          style: TextStyle(color: colors.text2, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          routineName,
          style: TextStyle(
            color: colors.text1,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _StatTile(
                label: 'Duration',
                value: durationLabel,
                colors: colors,
              ),
            ),
            Expanded(
              child: _StatTile(
                label: 'Volume',
                value: volumeLabel,
                colors: colors,
              ),
            ),
            Expanded(
              child: _StatTile(
                label: 'Status',
                value: statusLabel,
                colors: colors,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.colors,
  });
  final String label;
  final String value;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.text3,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: colors.text1,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
