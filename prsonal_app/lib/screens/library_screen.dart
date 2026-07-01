import 'package:flutter/material.dart';
import '../widgets/brand_title.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../services/library_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_fab_widget.dart';
import '../widgets/app_modal_widget.dart';
import '../widgets/app_skeleton_widget.dart';
import '../widgets/fade_rise_in_widget.dart';
import '../widgets/library_exercise_card_widget.dart';
import '../widgets/library_exercise_form_widget.dart';
import 'package:prsonal_app/theme/app_spacing.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  String _query = '';

  void _showForm({LibraryExercise? exercise}) {
    LibraryExerciseData? initial;
    if (exercise != null) {
      initial = LibraryExerciseData(
        id: exercise.id,
        name: exercise.name,
        type: exercise.type,
        primaryMuscles: exercise.primaryMuscles,
        secondaryMuscles: exercise.secondaryMuscles,
        notes: exercise.notes,
      );
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: LibraryExerciseForm(
          initial: initial,
          onSubmit: (data) async {
            Navigator.of(ctx).pop();
            final service = ref.read(libraryServiceProvider);
            if (data.id != null) {
              await service.updateExercise(
                data.id!,
                name: data.name,
                type: data.type,
                primaryMuscles: data.primaryMuscles,
                secondaryMuscles: data.secondaryMuscles,
                notes: data.notes,
              );
            } else {
              await service.createExercise(
                name: data.name,
                type: data.type,
                primaryMuscles: data.primaryMuscles,
                secondaryMuscles: data.secondaryMuscles,
                notes: data.notes,
              );
            }
          },
          onCancel: () => Navigator.of(ctx).pop(),
        ),
      ),
    );
  }

  Future<void> _deleteExercise(String id, String name) async {
    final ok = await showConfirmSheet(
      context,
      title: 'Delete exercise?',
      message: 'Delete "$name"?',
      confirmLabel: 'Delete',
    );
    if (ok) await ref.read(libraryServiceProvider).deleteExercise(id);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;
    final exercisesAsync = ref.watch(libraryListProvider);

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: const BrandTitle('Exercises'),
        backgroundColor: colors.bg,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(space4),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search',
                hintStyle: TextStyle(color: colors.text3),
                prefixIcon: Icon(Icons.search, color: colors.text3),
                filled: true,
                fillColor: colors.surface2,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.zero,
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: colors.text1),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          Expanded(
            child: exercisesAsync.when(
              data: (exercises) {
                final filtered = _query.isEmpty
                    ? exercises
                    : exercises
                          .where(
                            (e) => e.name.toLowerCase().contains(
                              _query.toLowerCase(),
                            ),
                          )
                          .toList();
                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      'No exercises yet',
                      style: TextStyle(color: colors.text2, fontSize: 16),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, i) {
                    final ex = filtered[i];
                    final musclesLabel = ex.primaryMuscles
                        .map((m) => m.label)
                        .join(', ');
                    return FadeRiseIn(
                      child: LibraryExerciseCard(
                        name: ex.name,
                        type: ex.type,
                        musclesLabel: musclesLabel,
                        prLabel: ex.bestOneRepMax != null
                            ? '1RM: ${ex.bestOneRepMax!.toStringAsFixed(1)}kg'
                            : null,
                        onTap: () => _showForm(exercise: ex),
                        onDelete: () => _deleteExercise(ex.id, ex.name),
                      ),
                    );
                  },
                );
              },
              loading: () => const _LibrarySkeleton(),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: AppFab(
        icon: Icons.add,
        tooltip: 'New exercise',
        onPressed: () => _showForm(),
      ),
    );
  }
}

/// Skeleton sketch of a loading exercise list (design_system.md "Motion &
/// life" — skeleton loaders, not a bare spinner).
class _LibrarySkeleton extends StatelessWidget {
  const _LibrarySkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: space4, vertical: 12),
      children: List.generate(
        6,
        (_) => const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: AppSkeleton(height: 48),
        ),
      ),
    );
  }
}
