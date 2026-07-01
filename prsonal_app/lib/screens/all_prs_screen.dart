import 'package:flutter/material.dart';
import '../widgets/brand_title.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/progress_providers.dart';
import '../theme/app_colors.dart';
import '../widgets/app_skeleton_widget.dart';
import '../widgets/fade_rise_in_widget.dart';
import '../widgets/pr_row_widget.dart';

class AllPrsScreen extends ConsumerWidget {
  const AllPrsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;
    final prsAsync = ref.watch(allPrsProvider);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: const BrandTitle('Personal Records'),
        backgroundColor: colors.bg,
      ),
      body: prsAsync.when(
        data: (prs) {
          if (prs.isEmpty) {
            return Center(
              child: Text(
                'No personal records yet',
                style: TextStyle(color: colors.text2, fontSize: 16),
              ),
            );
          }
          final fmt = DateFormat('d MMM yyyy');
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: prs.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, i) {
              final pr = prs[i];
              return FadeRiseIn(
                child: PrRow(
                  exerciseName: pr.exerciseName,
                  dateLabel: fmt.format(pr.date),
                  weightLabel: '${pr.weight}kg',
                  oneRmLabel: '1RM: ${pr.oneRepMax.toStringAsFixed(1)}kg',
                ),
              );
            },
          );
        },
        loading: () => const _AllPrsSkeleton(),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

/// Skeleton sketch of a loading PR list (design_system.md "Motion & life" —
/// skeleton loaders, not a bare spinner).
class _AllPrsSkeleton extends StatelessWidget {
  const _AllPrsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: List.generate(
        6,
        (_) => const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: AppSkeleton(height: 44),
        ),
      ),
    );
  }
}
