import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/routine_exercise.dart';
import '../services/session_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_button_widget.dart';
import '../widgets/app_modal_widget.dart';
import '../widgets/app_skeleton_widget.dart';
import '../widgets/exercise_form_widget.dart';
import '../widgets/session_header_widget.dart';
import '../widgets/session_progress_bar_widget.dart';
import '../widgets/set_row_widget.dart';
import '../providers/app_providers.dart';
import 'package:prsonal_app/theme/app_spacing.dart';

class SessionActiveScreen extends ConsumerStatefulWidget {
  const SessionActiveScreen({super.key});

  @override
  ConsumerState<SessionActiveScreen> createState() =>
      _SessionActiveScreenState();
}

class _SessionActiveScreenState extends ConsumerState<SessionActiveScreen> {
  // Per-active-set editable values
  String _primaryValue = '';
  String _secondaryValue = '';

  // Per-active-set bodyweight choice. Seeded from the set's routine value but
  // freely toggled during the workout; the chosen value is logged on complete.
  bool _isBodyweight = false;

  // The cursor the editable values were last seeded for. When the active set
  // changes we re-seed the inputs from the new set's planned targets.
  SessionCursor? _seededCursor;

  /// Seeds [_primaryValue]/[_secondaryValue]/[_isBodyweight] from the active
  /// set's planned targets so the inputs show the expected reps/weight rather
  /// than empty fields. No-op when the cursor has not changed since the last
  /// seed, so in-progress typing is preserved across rebuilds.
  void _seedForCursor(ActiveSessionState state) {
    if (_seededCursor == state.cursor) return;
    _seededCursor = state.cursor;
    final set = state.currentSet;
    _primaryValue = _plannedPrimary(set);
    _secondaryValue = _plannedSecondary(set);
    _isBodyweight = set?.isBodyweight ?? false;
  }

  String _plannedPrimary(ActiveSet? set) {
    final reps = set?.plannedReps;
    return reps != null ? '$reps' : '';
  }

  String _plannedSecondary(ActiveSet? set) {
    final weight = set?.plannedWeight;
    if (weight == null) return '';
    return weight == weight.truncateToDouble()
        ? weight.truncate().toString()
        : weight.toString();
  }

  Future<void> _completeCurrentSet(ActiveSet currentSet) async {
    final primary = num.tryParse(_primaryValue) ?? currentSet.plannedReps ?? 0;
    final secondary =
        num.tryParse(_secondaryValue) ?? currentSet.plannedWeight ?? 0;
    await ref
        .read(sessionEngineProvider.notifier)
        .markCurrentSetComplete(
          actualPrimary: primary,
          actualSecondary: secondary,
          isBodyweight: _isBodyweight,
        );
    // The cursor advances, so the next build re-seeds the inputs for the new
    // active set via [_seedForCursor].
  }

  void _onFinish() async {
    final confirmed = await showConfirmSheet(
      context,
      title: 'Finish workout?',
      confirmLabel: 'Save to history',
      cancelLabel: 'Keep going',
      confirmVariant: AppButtonVariant.accent,
    );
    if (!confirmed) return;
    await ref.read(sessionEngineProvider.notifier).finishSession();
    if (mounted) context.goNamed('history');
  }

  void _onQuit() async {
    final confirmed = await showConfirmSheet(
      context,
      title: 'Abandon workout?',
      confirmLabel: 'Abandon',
      cancelLabel: 'Continue',
      confirmVariant: AppButtonVariant.danger,
    );
    if (!confirmed) return;
    await ref.read(sessionEngineProvider.notifier).abandonSession();
    if (mounted) context.goNamed('session-pick');
  }

  void _showAddExercise(ActiveSessionState state) {
    final options = ref.read(libraryOptionsProvider).valueOrNull ?? const [];
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Add Exercise',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: space4),
            ExerciseForm(
              exercises: options,
              onSubmit: (data) async {
                Navigator.of(ctx).pop();
                if (data.exerciseId != null) {
                  final sets = data.sets
                      .map(
                        (s) => SetTarget.strength(
                          reps: s.reps,
                          weight: s.weight,
                          isBodyweight: s.isBodyweight,
                        ),
                      )
                      .toList();
                  await ref
                      .read(sessionEngineProvider.notifier)
                      .addExerciseToSession(
                        exerciseId: data.exerciseId!,
                        sets: sets,
                      );
                }
              },
              onCancel: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;
    final state = ref.watch(sessionEngineProvider);

    if (state == null) {
      return const Scaffold(body: SafeArea(child: _SessionActiveSkeleton()));
    }

    _seedForCursor(state);

    final isResting = state.resting;
    final restRemaining = state.restRemaining;
    final isLastSet = state.isLastSet;
    final currentSet = state.currentSet;

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: space4,
                vertical: 8,
              ),
              child: SessionHeader(
                routineName: state.session.routineName,
                elapsed: state.elapsed,
                onQuit: _onQuit,
                onFinish: _onFinish,
              ),
            ),
            SessionProgressBar(progress: state.progress),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(space4),
                itemCount: state.exercises.length + 1,
                itemBuilder: (context, i) {
                  if (i == state.exercises.length) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        onPressed: () => _showAddExercise(state),
                        icon: const Icon(Icons.add),
                        iconSize: 20,
                        tooltip: 'Add exercise',
                        color: colors.accent,
                      ),
                    );
                  }
                  final ex = state.exercises[i];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          ex.name,
                          style: TextStyle(
                            color: colors.text1,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      for (var si = 0; si < ex.sets.length; si++)
                        SetRow(
                          index: ex.sets[si].index,
                          kind: ex.sets[si].kind,
                          status: ex.sets[si].status,
                          plannedLabel: ex.sets[si].plannedLabel,
                          actualLabel: ex.sets[si].actualLabel,
                          isPR: ex.sets[si].isPR,
                          isBodyweight:
                              ex.isCurrent &&
                                  si == state.cursor.setIndex &&
                                  i == state.cursor.exerciseIndex
                              ? _isBodyweight
                              : ex.sets[si].isBodyweight,
                          onToggleBodyweight:
                              ex.isCurrent &&
                                  si == state.cursor.setIndex &&
                                  i == state.cursor.exerciseIndex
                              ? () => setState(
                                  () => _isBodyweight = !_isBodyweight,
                                )
                              : null,
                          primaryValue:
                              ex.isCurrent &&
                                  si == state.cursor.setIndex &&
                                  i == state.cursor.exerciseIndex
                              ? _primaryValue
                              : null,
                          secondaryValue:
                              ex.isCurrent &&
                                  si == state.cursor.setIndex &&
                                  i == state.cursor.exerciseIndex
                              ? _secondaryValue
                              : null,
                          onPrimaryChanged: (v) =>
                              setState(() => _primaryValue = v),
                          onSecondaryChanged: (v) =>
                              setState(() => _secondaryValue = v),
                          onToggleComplete:
                              ex.isCurrent &&
                                  si == state.cursor.setIndex &&
                                  i == state.cursor.exerciseIndex
                              ? () => _completeCurrentSet(ex.sets[si])
                              : null,
                          onSelect: () {
                            final notifier = ref.read(
                              sessionEngineProvider.notifier,
                            );
                            // A finished set is re-opened for editing (which
                            // clears its completion); any other selectable set
                            // just moves the cursor.
                            if (ex.sets[si].status ==
                                ActiveSetStatus.completed) {
                              notifier.uncheckSet(i, si);
                            } else {
                              notifier.jumpToSet(i, si);
                            }
                          },
                        ),
                    ],
                  );
                },
              ),
            ),
            // Bottom action button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: space4,
                vertical: 12,
              ),
              child: SizedBox(
                width: double.infinity,
                height: touchTargetMin,
                child: ElevatedButton(
                  onPressed: () async {
                    if (isResting) {
                      ref.read(sessionEngineProvider.notifier).cancelRest();
                    } else if (currentSet != null) {
                      await _completeCurrentSet(currentSet);
                    }
                  },
                  child: Text(
                    isResting
                        ? 'Rest ${restRemaining}s'
                        : isLastSet
                        ? 'Finish'
                        : 'Done',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Skeleton sketch of the active session screen while the session engine's
/// first state is still loading (design_system.md "Motion & life" —
/// skeleton loaders, not a bare spinner).
class _SessionActiveSkeleton extends StatelessWidget {
  const _SessionActiveSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: space4, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSkeleton(height: 48),
          SizedBox(height: space4),
          AppSkeleton(height: 6),
          SizedBox(height: space4),
          AppSkeleton(height: 64),
          SizedBox(height: space2),
          AppSkeleton(height: 64),
          SizedBox(height: space2),
          AppSkeleton(height: 64),
        ],
      ),
    );
  }
}
