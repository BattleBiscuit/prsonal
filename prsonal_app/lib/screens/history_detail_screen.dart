import 'package:flutter/material.dart';
import '../widgets/brand_title.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../services/history_service.dart';
import '../theme/app_colors.dart';
import '../widgets/history_set_table_widget.dart';
import '../widgets/workout_summary_header_widget.dart';

class HistoryDetailScreen extends ConsumerStatefulWidget {
  const HistoryDetailScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<HistoryDetailScreen> createState() =>
      _HistoryDetailScreenState();
}

class _HistoryDetailScreenState extends ConsumerState<HistoryDetailScreen> {
  SessionDetail? _detail;
  bool _loading = true;
  bool _editing = false;

  // For editing: maps set key -> controllers
  final Map<String, TextEditingController> _repsCtrl = {};
  final Map<String, TextEditingController> _weightCtrl = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in _repsCtrl.values) {
      c.dispose();
    }
    for (final c in _weightCtrl.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    final detail =
        await ref.read(historyServiceProvider).getDetail(widget.sessionId);
    setState(() {
      _detail = detail;
      _loading = false;
    });
  }

  void _enterEditMode() {
    final detail = _detail!;
    for (final ex in detail.exercises) {
      for (final s in ex.sets) {
        final key = '${ex.name}_${s.setIndex}';
        _repsCtrl.putIfAbsent(
            key, () => TextEditingController(text: s.actualLabel?.split('×').firstOrNull ?? ''));
        _weightCtrl.putIfAbsent(
            key, () => TextEditingController(text: s.actualLabel?.split('×').elementAtOrNull(1)?.replaceAll('kg', '') ?? ''));
      }
    }
    setState(() => _editing = true);
  }

  Future<void> _saveEdits() async {
    final service = ref.read(historyServiceProvider);
    final detail = _detail!;
    for (final ex in detail.exercises) {
      for (final s in ex.sets) {
        final key = '${ex.name}_${s.setIndex}';
        final repsText = _repsCtrl[key]?.text;
        final weightText = _weightCtrl[key]?.text;
        final reps = repsText != null && repsText.isNotEmpty
            ? int.tryParse(repsText)
            : null;
        final weight = weightText != null && weightText.isNotEmpty
            ? double.tryParse(weightText)
            : null;
        await service.updateSetActuals(
          s.id,
          reps: reps,
          weight: weight,
          isBodyweight: false,
          skipped: s.skipped,
        );
      }
    }
    setState(() => _editing = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final detail = _detail!;
    final dateFmt = DateFormat('d MMM yyyy, HH:mm');
    final statusLabel = detail.abandoned ? 'Abandoned' : 'Completed';
    final volumeLabel = '${detail.volume.toStringAsFixed(0)}kg';

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: BrandTitle(detail.routineName),
        backgroundColor: colors.bg,
        actions: [
          if (!_editing)
            TextButton(onPressed: _enterEditMode, child: const Text('Edit'))
          else
            TextButton(
                onPressed: _saveEdits, child: const Text('Save changes')),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          WorkoutSummaryHeader(
            routineName: detail.routineName,
            dateTimeLabel: dateFmt.format(detail.startedAt),
            durationLabel: detail.durationLabel,
            volumeLabel: volumeLabel,
            statusLabel: statusLabel,
          ),
          const SizedBox(height: 16),
          if (detail.prNames.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surface1,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PRs this session',
                    style: TextStyle(
                        color: colors.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  ...detail.prNames.map((name) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(name,
                            style: TextStyle(color: colors.text1, fontSize: 14)),
                      )),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          for (final ex in detail.exercises) ...[
            _editing
                ? _buildEditTable(ex, colors)
                : HistorySetTable(
                    exerciseName: ex.name, rows: ex.sets, editing: false),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Widget _buildEditTable(DetailExercise ex, AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(ex.name,
              style: TextStyle(
                  color: colors.text1,
                  fontSize: 15,
                  fontWeight: FontWeight.w600)),
        ),
        for (final s in ex.sets) _buildEditRow(ex.name, s, colors),
      ],
    );
  }

  Widget _buildEditRow(String exName, SetTableRow s, AppColors colors) {
    final key = '${exName}_${s.setIndex}';
    final repsC = _repsCtrl.putIfAbsent(key, () => TextEditingController());
    final weightC = _weightCtrl.putIfAbsent(key, () => TextEditingController());

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text('${s.setIndex + 1}',
                style: TextStyle(color: colors.text3, fontSize: 13)),
          ),
          Expanded(
            child: TextField(
              controller: repsC,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(hintText: 'Reps', isDense: true),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: weightC,
              keyboardType: TextInputType.number,
              decoration:
                  const InputDecoration(hintText: 'kg', isDense: true),
            ),
          ),
        ],
      ),
    );
  }
}
