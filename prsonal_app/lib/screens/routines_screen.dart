import 'package:flutter/material.dart';
import '../widgets/brand_title.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/app_providers.dart';
import '../services/routines_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_modal_widget.dart';
import '../widgets/routine_card_widget.dart';

Future<void> _showDeleteConfirm(
  BuildContext context,
  RoutinesService service,
  String routineId,
  String routineName,
) async {
  final ok = await showConfirmSheet(
    context,
    title: 'Delete routine?',
    message: 'Delete "$routineName"?',
    confirmLabel: 'Delete',
  );
  if (ok) await service.deleteRoutine(routineId);
}

class RoutinesScreen extends ConsumerWidget {
  const RoutinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;
    final routinesAsync = ref.watch(routinesListProvider);
    final service = ref.watch(routinesServiceProvider);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: const BrandTitle('Routines'),
        backgroundColor: colors.bg,
        actions: [
          TextButton(
            onPressed: () => context.goNamed('routine-create'),
            child: const Text('New'),
          ),
        ],
      ),
      body: routinesAsync.when(
        data: (routines) {
          if (routines.isEmpty) {
            return Center(
              child: Text(
                'No routines yet',
                style: TextStyle(color: colors.text2, fontSize: 16),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: routines.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, i) {
              final r = routines[i];
              return RoutineCard(
                name: r.name,
                metaLine:
                    '${r.exerciseCount} exercise${r.exerciseCount == 1 ? '' : 's'}',
                notes: r.notes,
                onTap: () => context.goNamed(
                  'routine-edit',
                  pathParameters: {'id': r.id},
                ),
                onDelete: () =>
                    _showDeleteConfirm(context, service, r.id, r.name),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
