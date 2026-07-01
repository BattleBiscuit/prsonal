import 'package:flutter/material.dart';
import '../widgets/brand_title.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/progress_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../widgets/app_skeleton_widget.dart';
import '../widgets/chart_slider_widget.dart';
import '../widgets/pr_row_widget.dart';
import '../widgets/radar_chart_widget.dart';
import '../widgets/stat_card_widget.dart';
import '../widgets/volume_chart_widget.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;
    final range = ref.watch(progressRangeProvider);
    final summaryAsync = ref.watch(progressSummaryProvider);
    final prsAsync = ref.watch(recentPrsProvider);
    final historyAsync = ref.watch(historyPreviewProvider);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: const BrandTitle('Progress'),
        backgroundColor: colors.bg,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: space4, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Range toggles
            Row(
              children: [
                for (final r in [7, 28, 56, 90]) ...[
                  _RangeButton(
                    label: r == 7
                        ? '7d'
                        : r == 28
                        ? '4w'
                        : r == 56
                        ? '8w'
                        : '90d',
                    selected: range == r,
                    onTap: () =>
                        ref.read(progressRangeProvider.notifier).state = r,
                  ),
                  const SizedBox(width: space2),
                ],
              ],
            ),
            const SizedBox(height: space2),
            // Metric cards — compact 2×2 grid
            summaryAsync.when(
              data: (summary) => Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          value: '${summary.workoutCount}',
                          label: 'Workouts',
                          icon: Icons.fitness_center_outlined,
                        ),
                      ),
                      const SizedBox(width: space2),
                      Expanded(
                        child: StatCard(
                          value: summary.volumeTrendPercent != null
                              ? '${summary.volumeTrendPercent!.toStringAsFixed(0)}%'
                              : '—',
                          label: 'Volume trend',
                          icon: Icons.trending_up,
                          tone: (summary.volumeTrendPercent ?? 0) >= 0
                              ? StatTone.success
                              : StatTone.danger,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: space2),
                  Row(
                    children: [
                      Expanded(
                        child: StatCard(
                          value: summary.adherencePercent != null
                              ? '${summary.adherencePercent!.toStringAsFixed(0)}%'
                              : '—',
                          label: 'Plan adherence',
                          icon: Icons.calendar_today_outlined,
                        ),
                      ),
                      const SizedBox(width: space2),
                      Expanded(
                        child: StatCard(
                          value: '${summary.bestStreak}',
                          label: 'Best streak',
                          icon: Icons.local_fire_department_outlined,
                          tone: StatTone.warning,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              loading: () => const SizedBox(
                height: 80,
                child: Row(
                  children: [
                    Expanded(child: AppSkeleton(height: 80)),
                    SizedBox(width: space2),
                    Expanded(child: AppSkeleton(height: 80)),
                  ],
                ),
              ),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: space2),
            // Chart slider — muscle balance + volume
            summaryAsync.when(
              data: (summary) => SizedBox(
                height: 240,
                child: ChartSlider(
                  titles: const ['Muscle Balance', 'Volume'],
                  pages: [
                    MuscleRadarChart(data: summary.muscleBalance),
                    VolumeChart(data: summary.sessionVolumes),
                  ],
                ),
              ),
              loading: () => const SizedBox(
                height: 240,
                child: Padding(
                  padding: EdgeInsets.all(space4),
                  child: AppSkeleton(height: 208),
                ),
              ),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: space2),
            // Recent PRs
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent PRs',
                  style: TextStyle(
                    color: colors.text1,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => context.goNamed('all-prs'),
                  icon: const Icon(Icons.chevron_right_outlined),
                  iconSize: 20,
                  tooltip: 'View all PRs',
                  color: colors.text2,
                ),
              ],
            ),
            const SizedBox(height: space1),
            prsAsync.when(
              data: (prs) {
                final dateFmt = DateFormat('d MMM yyyy');
                return Column(
                  children: [
                    for (var j = 0; j < prs.length; j++) ...[
                      if (j > 0) const Divider(),
                      PrRow(
                        exerciseName: prs[j].exerciseName,
                        dateLabel: dateFmt.format(prs[j].date),
                        weightLabel: '${prs[j].weight}kg',
                        oneRmLabel:
                            '1RM: ${prs[j].oneRepMax.toStringAsFixed(1)}kg',
                      ),
                    ],
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (e, _) => Text('Error: $e'),
            ),
            const SizedBox(height: space2),
            // History preview
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent sessions',
                  style: TextStyle(
                    color: colors.text1,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: () => context.goNamed('history'),
                  icon: const Icon(Icons.chevron_right_outlined),
                  iconSize: 20,
                  tooltip: 'View all history',
                  color: colors.text2,
                ),
              ],
            ),
            const SizedBox(height: space1),
            historyAsync.when(
              data: (sessions) => Column(
                children: [
                  for (var j = 0; j < sessions.length; j++) ...[
                    if (j > 0) const Divider(),
                    ListTile(
                      dense: true,
                      title: Text(
                        sessions[j].routineName,
                        style: TextStyle(color: colors.text1),
                      ),
                      subtitle: Text(
                        sessions[j].durationLabel,
                        style: TextStyle(color: colors.text2),
                      ),
                      trailing: Icon(
                        Icons.chevron_right_outlined,
                        color: colors.text2,
                      ),
                      onTap: () => context.goNamed(
                        'history-detail',
                        pathParameters: {'id': sessions[j].id},
                      ),
                    ),
                  ],
                ],
              ),
              loading: () => const SizedBox.shrink(),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }
}

class _RangeButton extends StatelessWidget {
  const _RangeButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: space3, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? colors.accent : colors.surface2,
          borderRadius: BorderRadius.circular(radiusFull),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? colors.onAccent : colors.text2,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
