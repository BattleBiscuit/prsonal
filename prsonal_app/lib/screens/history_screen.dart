import 'package:flutter/material.dart';
import '../widgets/brand_title.dart';
import '../widgets/app_modal_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../services/history_service.dart';
import '../theme/app_colors.dart';
import '../widgets/app_skeleton_widget.dart';
import '../widgets/fade_rise_in_widget.dart';
import '../widgets/history_card_widget.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  static const _pageSize = 20;
  final List<SessionSummary> _sessions = [];
  int _currentPage = 0;
  bool _loading = false;
  bool _hasMore = true;
  final ScrollController _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadPage();
    _scrollCtrl.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >=
            _scrollCtrl.position.maxScrollExtent - 200 &&
        !_loading &&
        _hasMore) {
      _loadPage();
    }
  }

  Future<void> _loadPage() async {
    if (_loading) return;
    setState(() => _loading = true);
    final service = ref.read(historyServiceProvider);
    final nextPage = _currentPage + 1;
    final page = await service.loadPage(page: nextPage, pageSize: _pageSize);
    setState(() {
      _currentPage = nextPage;
      _sessions.addAll(page);
      _loading = false;
      if (page.length < _pageSize) _hasMore = false;
    });
  }

  Future<void> _deleteSession(String id) async {
    final ok = await showConfirmSheet(
      context,
      title: 'Delete workout?',
      confirmLabel: 'Delete',
    );
    if (!ok) return;
    await ref.read(historyServiceProvider).deleteSession(id);
    if (mounted) setState(() => _sessions.removeWhere((s) => s.id == id));
  }

  /// Group sessions by 'MMMM yyyy' label.
  Map<String, List<SessionSummary>> _grouped() {
    final fmt = DateFormat('MMMM yyyy');
    final map = <String, List<SessionSummary>>{};
    for (final s in _sessions) {
      final key = fmt.format(s.startedAt);
      map.putIfAbsent(key, () => []).add(s);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;

    if (!_loading && _sessions.isEmpty && !_hasMore) {
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

    final grouped = _grouped();
    final groupKeys = grouped.keys.toList();

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: const BrandTitle('History'),
        backgroundColor: colors.bg,
      ),
      body: _sessions.isEmpty && _loading
          ? const _HistorySkeleton()
          : ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: groupKeys.length + (_loading ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == groupKeys.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                final key = groupKeys[i];
                final sessions = grouped[key]!;
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
                      for (var j = 0; j < sessions.length; j++) ...[
                        if (j > 0) const Divider(),
                        HistoryCard(
                          routineName: sessions[j].routineName,
                          dateLabel: dateFmt.format(sessions[j].startedAt),
                          metaLabel: sessions[j].abandoned
                              ? sessions[j].durationLabel
                              : '${sessions[j].durationLabel} · ${sessions[j].volume.toStringAsFixed(0)}kg',
                          abandoned: sessions[j].abandoned,
                          onTap: () => context.goNamed(
                            'history-detail',
                            pathParameters: {'id': sessions[j].id},
                          ),
                          onDelete: () => _deleteSession(sessions[j].id),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
