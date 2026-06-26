import 'package:flutter/material.dart';
import '../widgets/brand_title.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/session_pick_providers.dart';
import '../services/session_service.dart';
import '../theme/app_colors.dart';
import '../widgets/plan_entry_row_widget.dart';

class SessionPickScreen extends ConsumerWidget {
  const SessionPickScreen({super.key});

  void _showAddSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('New routine'),
              onTap: () {
                Navigator.of(ctx).pop();
                context.goNamed('routine-create');
              },
            ),
            ListTile(
              title: const Text('New plan'),
              onTap: () {
                Navigator.of(ctx).pop();
                context.goNamed('plan-create');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;
    final plans = ref.watch(activePlansViewProvider);
    final unplanned = ref.watch(unplannedRoutinesProvider);
    final bool isEmpty = plans.isEmpty && unplanned.isEmpty;

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(title: const BrandTitle('Workout')),
      body: SafeArea(
        child: isEmpty
            ? Center(
                child: Text(
                  'Nothing here yet',
                  style: TextStyle(color: colors.text2, fontSize: 16),
                ),
              )
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  for (final plan in plans) ...[
                    _PlanBlock(plan: plan),
                    const SizedBox(height: 16),
                  ],
                  if (unplanned.isNotEmpty) ...[
                    Text(
                      'Unplanned',
                      style: TextStyle(
                        color: colors.text1,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final r in unplanned)
                      PlanEntryRow(
                        dayLabel: '',
                        routineName: r.name,
                        done: false,
                        onStart: () {
                          context.goNamed('session-active');
                          ref
                              .read(sessionEngineProvider.notifier)
                              .startSession(routineId: r.id)
                              .catchError((_) {});
                        },
                      ),
                  ],
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context),
        label: const Text('Add'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _PlanBlock extends ConsumerWidget {
  const _PlanBlock({required this.plan});

  final PlanView plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface1,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  plan.name,
                  style: TextStyle(
                    color: colors.text1,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (plan.streak > 0) ...[
                const SizedBox(width: 8),
                Text(
                  '${plan.streak}',
                  style: TextStyle(
                    color: colors.accent,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Icon(Icons.local_fire_department,
                    color: colors.accent, size: 18),
              ],
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => context
                    .goNamed('plan-edit', pathParameters: {'id': plan.id}),
                child: Icon(Icons.edit_outlined, color: colors.text3, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final entry in plan.entries)
            PlanEntryRow(
              dayLabel: entry.dayLabel ?? '',
              routineName: entry.routineName,
              done: entry.doneThisWeek,
              onStart: () {
                // Navigate first so the active-session screen starts building
                // while startSession() runs in the background.
                context.goNamed('session-active');
                ref
                    .read(sessionEngineProvider.notifier)
                    .startSession(
                      routineId: entry.routineId,
                      planId: plan.id,
                      planEntryId: entry.entryId,
                    )
                    .catchError((_) {});
              },
            ),
        ],
      ),
    );
  }
}
