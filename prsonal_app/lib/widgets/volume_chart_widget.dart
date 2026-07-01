import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:prsonal_app/theme/app_colors.dart';
import 'package:prsonal_app/theme/app_motion.dart';
import 'package:prsonal_app/theme/app_typography.dart';

class VolumeChart extends StatefulWidget {
  const VolumeChart({super.key, required this.data});

  final List<({String label, double volume})> data;

  @override
  State<VolumeChart> createState() => _VolumeChartState();
}

class _VolumeChartState extends State<VolumeChart>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  static const _staggerPerBar = Duration(milliseconds: 40);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_controller == null &&
        widget.data.isNotEmpty &&
        !MediaQuery.of(context).disableAnimations) {
      final total =
          AppDurations.normal + _staggerPerBar * (widget.data.length - 1);
      _controller = AnimationController(vsync: this, duration: total)
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// Bar i grows over its own [AppDurations.normal] window, staggered by
  /// [_staggerPerBar] per index (design_system.md: "Bars grow on load
  /// (normal, staggered)").
  double _growthFor(int index, int total) {
    final controller = _controller;
    if (controller == null) return 1.0;
    final totalMs = controller.duration!.inMilliseconds;
    final startMs = _staggerPerBar.inMilliseconds * index;
    final spanMs = AppDurations.normal.inMilliseconds;
    final interval = Interval(
      startMs / totalMs,
      ((startMs + spanMs) / totalMs).clamp(0.0, 1.0),
      curve: Curves.easeOut,
    );
    return interval.transform(controller.value);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;

    if (widget.data.isEmpty) {
      return Center(
        child: Text(
          'No volume yet',
          style: TextStyle(color: colors.text3, fontSize: 14),
        ),
      );
    }

    final maxVol = widget.data
        .map((d) => d.volume)
        .reduce((a, b) => a > b ? a : b);

    Widget buildChart() {
      return BarChart(
        BarChartData(
          maxY: maxVol * 1.2,
          barGroups: widget.data.asMap().entries.map((entry) {
            final isLatest = entry.key == widget.data.length - 1;
            final growth = _growthFor(entry.key, widget.data.length);
            return BarChartGroupData(
              x: entry.key,
              barRods: [
                BarChartRodData(
                  toY: entry.value.volume * growth,
                  color: isLatest
                      ? colors.accent
                      : colors.accent.withValues(alpha: 0.50),
                  width: 16,
                  borderRadius: BorderRadius.zero,
                ),
              ],
            );
          }).toList(),
          gridData: FlGridData(show: false),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: colors.surface3, width: 1),
            ),
          ),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                  final idx = val.toInt();
                  if (idx < 0 || idx >= widget.data.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      widget.data[idx].label,
                      style: monoNumerals(
                        TextStyle(color: colors.text2, fontSize: 10),
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
        ),
      );
    }

    if (_controller == null) {
      return buildChart();
    }

    return AnimatedBuilder(
      animation: _controller!,
      builder: (context, child) => buildChart(),
    );
  }
}
