import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/exercise.dart';
import '../services/history_service.dart';
import '../services/progress_service.dart';
import 'app_providers.dart';

export '../services/progress_service.dart' show PRItem, MuscleMode;
export '../services/history_service.dart' show SessionSummary;

// ---------------------------------------------------------------------------
// ProgressSummary view-model
// ---------------------------------------------------------------------------

class ProgressSummary {
  const ProgressSummary({
    required this.workoutCount,
    this.volumeTrendPercent,
    this.adherencePercent,
    required this.bestStreak,
    required this.muscleBalance,
    required this.sessionVolumes,
  });

  final int workoutCount;
  final double? volumeTrendPercent;
  final double? adherencePercent;
  final int bestStreak;
  final Map<Muscle, double> muscleBalance;
  final List<({String label, double volume})> sessionVolumes;
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// The selected range in days. Default = 28.
final progressRangeProvider = StateProvider<int>((ref) => 28);

/// Aggregated summary for the progress screen.
final progressSummaryProvider = FutureProvider<ProgressSummary>((ref) async {
  final range = ref.watch(progressRangeProvider);
  final service = ref.watch(progressServiceProvider);
  final now = ref.read(nowProvider)();

  final count = await service.workoutCount(range, asOf: now);
  final trend = await service.volumeTrendPercent(range, asOf: now);
  final adherence = await service.planAdherencePercent(range, asOf: now);

  // Best streak: look at all plans' streaks and take the max.
  // For simplicity, compute bestStreak as 0 if no data (could be expanded).
  final vols = await service.sessionVolumes(range, asOf: now);
  final sessionVolumes = vols
      .map((v) => (label: v.label, volume: v.volume))
      .toList();

  final freqs = await service.muscleFrequency(range, MuscleMode.session, asOf: now);
  final muscleBalance = <Muscle, double>{
    for (final f in freqs) f.muscle: f.count,
  };

  return ProgressSummary(
    workoutCount: count,
    volumeTrendPercent: trend,
    adherencePercent: adherence,
    bestStreak: 0,
    muscleBalance: muscleBalance,
    sessionVolumes: sessionVolumes,
  );
});

/// Recent PRs in the selected range.
final recentPrsProvider = FutureProvider<List<PRItem>>((ref) async {
  final range = ref.watch(progressRangeProvider);
  final service = ref.watch(progressServiceProvider);
  final now = ref.read(nowProvider)();
  return service.recentPRs(range, asOf: now);
});

/// Last few sessions for the history preview on the progress screen.
final historyPreviewProvider = FutureProvider<List<SessionSummary>>((ref) async {
  final service = ref.watch(historyServiceProvider);
  return service.loadPage(page: 1, pageSize: 5);
});

/// All PRs across all time.
final allPrsProvider = FutureProvider<List<PRItem>>((ref) async {
  final service = ref.watch(progressServiceProvider);
  return service.allPRs();
});
