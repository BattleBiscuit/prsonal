import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:prsonal_app/models/exercise.dart';
import 'package:prsonal_app/theme/app_colors.dart';

class MuscleRadarChart extends StatelessWidget {
  const MuscleRadarChart({super.key, required this.data});

  final Map<Muscle, double> data;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;

    if (data.isEmpty) {
      return Center(
        child: Text(
          'Not enough data yet',
          style: TextStyle(color: colors.text3, fontSize: 14),
        ),
      );
    }

    final muscles = data.keys.toList();
    final values = muscles.map((m) => data[m]!).toList();

    return RadarChart(
      RadarChartData(
        radarShape: RadarShape.polygon,
        tickCount: 4,
        ticksTextStyle: const TextStyle(fontSize: 0),
        gridBorderData: BorderSide(color: colors.border, width: 1),
        radarBorderData: BorderSide(color: colors.border, width: 1),
        titlePositionPercentageOffset: 0.2,
        getTitle: (index, angle) =>
            RadarChartTitle(text: muscles[index].label, angle: angle),
        dataSets: [
          RadarDataSet(
            fillColor: colors.accent.withValues(alpha: 0.2),
            borderColor: colors.accent,
            borderWidth: 2,
            entryRadius: 3,
            dataEntries: values.map((v) => RadarEntry(value: v)).toList(),
          ),
        ],
        tickBorderData: BorderSide(color: colors.border),
      ),
    );
  }
}
