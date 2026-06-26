import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:prsonal_app/theme/app_colors.dart';

class VolumeChart extends StatelessWidget {
  const VolumeChart({super.key, required this.data});

  final List<({String label, double volume})> data;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;

    if (data.isEmpty) {
      return Center(
        child: Text('No volume yet', style: TextStyle(color: colors.text3, fontSize: 14)),
      );
    }

    final maxVol = data.map((d) => d.volume).reduce((a, b) => a > b ? a : b);

    return BarChart(
      BarChartData(
        maxY: maxVol * 1.2,
        barGroups: data.asMap().entries.map((entry) => BarChartGroupData(
          x: entry.key,
          barRods: [
            BarChartRodData(
              toY: entry.value.volume,
              color: colors.accent,
              width: 16,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            ),
          ],
        )).toList(),
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (val, meta) {
                final idx = val.toInt();
                if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(data[idx].label, style: TextStyle(color: colors.text2, fontSize: 10)),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
      ),
    );
  }
}
