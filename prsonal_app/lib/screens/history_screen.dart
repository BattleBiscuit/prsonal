import 'package:flutter/material.dart';
import '../widgets/brand_title.dart';
import '../widgets/app_modal_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/history_providers.dart';
import '../services/history_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_skeleton_widget.dart';
import '../widgets/fade_rise_in_widget.dart';
import '../widgets/history_card_widget.dart';
import 'package:prsonal_app/theme/app_spacing.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  // Purely ephemeral — the scroll position itself, not app data.
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    final pageAsync = ref.read(historyPageProvider);
    final sessions = pageAsync.valueOrNull ?? const <SessionSummary>[];
    final hasMore = sessions.length >= ref.read(historyPageSizeProvider);
    if (!pageAsync.isLoading &&
        hasMore &&
        _scrollCtrl.position.pixels >=
            _scrollCtrl.position.maxScrollExtent - 200) {
      ref.read(historyPageSizeProvider.notifier).loadMore();
    }
  }

  Future<void> _deleteSession(String id) async {
    final ok = await showConfirmSheet(
      context,
      title: 'Delete workout?',
      confirmLabel: 'Delete',
    );
    if (!ok) return;
    // No manual list patch — historyPageProvider is Drift-stream-backed and
    // re-emits on its own once the session is gone.
    await ref.read(historyServiceProvider).deleteSession(id);
  }

  /// Group sessions by 'MMMM yyyy' label.
  Map<String, List<SessionSummary>> _grouped(List<SessionSummary> sessions) {
    final fmt = DateFormat('MMMM yyyy');
    final map = <String, List<SessionSummary>>{};
    for (final s in sessions) {
      final key = fmt.format(s.startedAt);
      map.putIfAbsent(key, () => []).add(s);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;
    final pageAsync = ref.watch(historyPageProvider);
    final sessions = pageAsync.valueOrNull ?? const <SessionSummary>[];
    final initialLoading = pageAsync.isLoading && sessions.isEmpty;
    final loadingMore = pageAsync.isLoading && sessions.isNotEmpty;

    if (!initialLoading && sessions.isEmpty) {
      return Scaffold(
        backgroundColor: colors.bg,
        appBar: AppBar(
          title: const BrandTitle('History'),
          backgroundColor: colors.bg,
        ),
        body: Center(
          child: Text(
            'No workouts yet',
            style: TextStyle(color: colors.text2, fontSize: 16),
          ),
        ),
      );
    }

    final grouped = _grouped(sessions);
    final groupKeys = grouped.keys.toList();

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: const BrandTitle('History'),
        backgroundColor: colors.bg,
      ),
      body: initialLoading
          ? const _HistorySkeleton()
          : ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: groupKeys.length + (loadingMore ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == groupKeys.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(space4),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final key = groupKeys[i];
                final sessionsInGroup = grouped[key]!;
                final dateFmt = DateFormat('d MMM');
                return FadeRiseIn(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                        child: Text(
                          key,
                          style: TextStyle(
                            color: colors.text2,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      for (var j = 0; j < sessionsInGroup.length; j++) ...[
                        if (j > 0) const Divider(),
                        HistoryCard(
                          routineName: sessionsInGroup[j].routineName,
                          dateLabel: dateFmt.format(
                            sessionsInGroup[j].startedAt,
                          ),
                          metaLabel: sessionsInGroup[j].abandoned
                              ? sessionsInGroup[j].durationLabel
                              : '${sessionsInGroup[j].durationLabel} · ${sessionsInGroup[j].volume.toStringAsFixed(0)}kg',
                          abandoned: sessionsInGroup[j].abandoned,
                          onTap: () => context.goNamed(
                            'history-detail',
                            pathParameters: {'id': sessionsInGroup[j].id},
                          ),
                          onDelete: () => _deleteSession(sessionsInGroup[j].id),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }
}

/// Skeleton sketch of a loading history list (design_system.md "Motion &
/// life" — skeleton loaders, not a bare spinner).
class _HistorySkeleton extends StatelessWidget {
  const _HistorySkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: space4, vertical: 12),
      children: List.generate(
        6,
        (_) => const Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: AppSkeleton(height: 56),
        ),
      ),
    );
  }
}
