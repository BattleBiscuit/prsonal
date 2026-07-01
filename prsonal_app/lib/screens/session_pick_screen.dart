import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/session_pick_providers.dart';
import '../services/session_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_page_shell_widget.dart';
import '../widgets/fade_rise_in_widget.dart';
import '../widgets/plan_entry_row_widget.dart';
import 'package:prsonal_app/theme/app_spacing.dart';

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
              trailing: const Icon(Icons.chevron_right_outlined),
              onTap: () {
                Navigator.of(ctx).pop();
                context.goNamed('routine-create');
              },
            ),
            ListTile(
              title: const Text('New plan'),
              trailing: const Icon(Icons.chevron_right_outlined),
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
    final engine = ref.watch(sessionEngineProvider);
    final bool isEmpty = plans.isEmpty && unplanned.isEmpty;

    return AppPageShell(
      showWorkoutBanner: engine != null,
      workoutRoutineName: engine?.session.routineName,
      onResumeWorkout: () => context.goNamed('session-active'),
      header: Tooltip(
        message: 'Add',
        child: Semantics(
          label: 'Add routine or plan',
          button: true,
          child: GestureDetector(
            onTap: () => _showAddSheet(context),
            child: Icon(Icons.add, color: colors.accent, size: 28),
          ),
        ),
      ),
      child: isEmpty
          ? Center(
              child: Text(
                'Nothing here yet',
                style: TextStyle(color: colors.text2, fontSize: 16),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(space4),
              children: [
                for (final plan in plans) ...[
                  FadeRiseIn(child: _PlanBlock(plan: plan)),
                  const SizedBox(height: space4),
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
                  const SizedBox(height: space2),
                  for (int i = 0; i < unplanned.length; i++) ...[
                    if (i > 0) const Divider(),
                    FadeRiseIn(
                      child: PlanEntryRow(
                        dayLabel: '',
                        routineName: unplanned[i].name,
                        done: false,
                        onOpen: () => context.goNamed(
                          'routine-edit',
                          pathParameters: {'id': unplanned[i].id},
                        ),
                        onStart: () {
                          context.goNamed('session-active');
                          ref
                              .read(sessionEngineProvider.notifier)
                              .startSession(routineId: unplanned[i].id)
                              .catchError((_) {});
                        },
                      ),
                    ),
                  ],
                ],
              ],
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

    return Padding(
      padding: const EdgeInsets.all(space4),
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
                const SizedBox(width: space2),
                Text(
                  '${plan.streak}',
                  style: TextStyle(
                    color: colors.warning,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Icon(
                  Icons.local_fire_department_outlined,
                  color: colors.warning,
                  size: 18,
                ),
              ],
              const SizedBox(width: space2),
              Tooltip(
                message: 'Edit plan',
                child: Semantics(
                  label: 'Edit ${plan.name}',
                  button: true,
                  child: GestureDetector(
                    onTap: () => context.goNamed(
                      'plan-edit',
                      pathParameters: {'id': plan.id},
                    ),
                    child: Icon(
                      Icons.edit_outlined,
                      color: colors.text3,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: space2),
          for (int i = 0; i < plan.entries.length; i++) ...[
            if (i > 0) const Divider(),
            PlanEntryRow(
              dayLabel: plan.entries[i].dayLabel ?? '',
              routineName: plan.entries[i].routineName,
              done: plan.entries[i].doneThisWeek,
              onOpen: () => context.goNamed(
                'routine-edit',
                pathParameters: {'id': plan.entries[i].routineId},
              ),
              onStart: () {
                // Navigate first so the active-session screen starts building
                // while startSession() runs in the background.
                context.goNamed('session-active');
                ref
                    .read(sessionEngineProvider.notifier)
                    .startSession(
                      routineId: plan.entries[i].routineId,
                      planId: plan.id,
                      planEntryId: plan.entries[i].entryId,
                    )
                    .catchError((_) {});
              },
            ),
          ],
        ],
      ),
    );
  }
}
