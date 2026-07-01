import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:prsonal_app/models/exercise.dart';
import 'package:prsonal_app/theme/app_colors.dart';
import 'package:prsonal_app/theme/app_motion.dart';

class MuscleRadarChart extends StatelessWidget {
  const MuscleRadarChart({super.key, required this.data});

  final Map<Muscle, double> data;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;

    // Plot the seven fixed muscle axes (missing muscles treated as 0) so the
    // radar always has a stable shape. This also keeps the dataset at 7
    // entries — fl_chart throws for a RadarDataSet with 1 or 2 entries.
    final muscles = Muscle.values;
    final values = muscles.map((m) => data[m] ?? 0.0).toList();

    // Empty state when there is nothing to show (all counts zero).
    if (values.every((v) => v == 0)) {
      return Center(
        child: Text(
          'Not enough data yet',
          style: TextStyle(color: colors.text3, fontSize: 14),
        ),
      );
    }

    final chart = RadarChart(
      RadarChartData(
        radarShape: RadarShape.polygon,
        tickCount: 4,
        ticksTextStyle: const TextStyle(fontSize: 0),
        gridBorderData: BorderSide(color: colors.surface3, width: 1),
        radarBorderData: BorderSide(color: colors.surface3, width: 1),
        titlePositionPercentageOffset: 0.2,
        titleTextStyle: TextStyle(fontSize: 12, color: colors.text2),
        // angle: 0 (not the axis's radial `angle`) — the label must stay
        // upright and readable at every position around the chart, not
        // rotate to follow the spoke it sits on.
        getTitle: (index, angle) =>
            RadarChartTitle(text: muscles[index].label, angle: 0),
        dataSets: [
          RadarDataSet(
            fillColor: colors.accent.withValues(alpha: 0.12),
            borderColor: colors.accent,
            borderWidth: 2,
            entryRadius: 3,
            dataEntries: values.map((v) => RadarEntry(value: v)).toList(),
          ),
        ],
        tickBorderData: BorderSide(color: colors.surface3),
      ),
    );

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: AppDurations.normal,
      curve: Curves.easeOut,
      builder: (context, scale, child) => Transform.scale(
        key: const ValueKey('radarChartScale'),
        scale: scale,
        child: child,
      ),
      child: chart,
    );
  }
}
