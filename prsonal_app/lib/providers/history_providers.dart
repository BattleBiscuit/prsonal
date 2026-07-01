import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/history_service.dart';

export '../services/history_service.dart' show SessionSummary;

/// Number of sessions currently visible on the History screen — grows by
/// [pageSize] each time the user scrolls to the bottom.
class HistoryPageSizeNotifier extends AutoDisposeNotifier<int> {
  static const pageSize = 20;

  @override
  int build() => pageSize;

  void loadMore() => state += pageSize;
}

final historyPageSizeProvider =
    NotifierProvider.autoDispose<HistoryPageSizeNotifier, int>(
      HistoryPageSizeNotifier.new,
    );

/// Reactive, newest-first session list capped at [historyPageSizeProvider].
/// Drift-backed — recomputed by the database, never hand-maintained.
final historyPageProvider = StreamProvider.autoDispose<List<SessionSummary>>((
  ref,
) {
  final limit = ref.watch(historyPageSizeProvider);
  final service = ref.watch(historyServiceProvider);
  return service.watchPage(limit);
});
