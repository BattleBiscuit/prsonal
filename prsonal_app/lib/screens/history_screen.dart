import 'package:flutter/material.dart';
import '../widgets/brand_title.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../services/history_service.dart';
import '../theme/app_colors.dart';
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
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete workout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(historyServiceProvider).deleteSession(id);
              setState(() => _sessions.removeWhere((s) => s.id == id));
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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
        appBar: AppBar(title: const BrandTitle('History'), backgroundColor: colors.bg),
        body: Center(
          child: Text('No workouts yet',
              style: TextStyle(color: colors.text2, fontSize: 16)),
        ),
      );
    }

    final grouped = _grouped();
    final groupKeys = grouped.keys.toList();

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(title: const BrandTitle('History'), backgroundColor: colors.bg),
      body: _sessions.isEmpty && _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              itemCount: groupKeys.length + (_loading ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == groupKeys.length) {
                  return const Center(
                      child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ));
                }
                final key = groupKeys[i];
                final sessions = grouped[key]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        key,
                        style: TextStyle(
                          color: colors.text2,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ...sessions.map((s) {
                      final dateFmt = DateFormat('d MMM');
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: HistoryCard(
                          routineName: s.routineName,
                          dateLabel: dateFmt.format(s.startedAt),
                          metaLabel: s.abandoned
                              ? s.durationLabel
                              : '${s.durationLabel} · ${s.volume.toStringAsFixed(0)}kg',
                          abandoned: s.abandoned,
                          onTap: () => context.goNamed(
                            'history-detail',
                            pathParameters: {'id': s.id},
                          ),
                          onDelete: () => _deleteSession(s.id),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
    );
  }
}
