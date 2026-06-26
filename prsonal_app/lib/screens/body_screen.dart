import 'package:flutter/material.dart';
import '../widgets/brand_title.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/body_metric.dart';
import '../services/body_service.dart';
import '../theme/app_colors.dart';
import '../widgets/body_metric_card_widget.dart';

class BodyScreen extends ConsumerStatefulWidget {
  const BodyScreen({super.key});

  @override
  ConsumerState<BodyScreen> createState() => _BodyScreenState();
}

class _BodyScreenState extends ConsumerState<BodyScreen> {
  static final Map<BodyMetricType, IconData> _icons = {
    BodyMetricType.weight: Icons.monitor_weight_outlined,
    BodyMetricType.bodyfat: Icons.percent,
    BodyMetricType.waist: Icons.straighten,
    BodyMetricType.chest: Icons.accessibility_new,
    BodyMetricType.arms: Icons.fitness_center,
    BodyMetricType.legs: Icons.directions_run,
  };

  void _showLogSheet(BodyMetricType type) {
    final ctrl = TextEditingController();
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
            Text(
              'Log ${type.label}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: '${type.label} (${type.unit})',
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final value = double.tryParse(ctrl.text);
                if (value == null) return;
                Navigator.of(ctx).pop();
                await ref.read(bodyServiceProvider).log(type, value);
              },
              child: const Text('Log'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;
    final service = ref.watch(bodyServiceProvider);
    final dateFmt = DateFormat('d MMM');

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: const BrandTitle('Body'),
        backgroundColor: colors.bg,
      ),
      body: StreamBuilder<Map<BodyMetricType, BodyMetric?>>(
        stream: service.watchLatest(),
        builder: (context, latestSnap) {
          final latest = latestSnap.data ?? const {};
          return StreamBuilder<List<BodyMetric>>(
            stream: service.watchHistory(BodyMetricType.weight, days: 90),
            builder: (context, historySnap) {
              final weightHistory = historySnap.data ?? const [];
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2-column grid of metric cards, built eagerly
                    for (var row = 0; row < 3; row++) ...[
                      Row(
                        children: [
                          for (var col = 0; col < 2; col++) ...[
                            Expanded(
                              child: Builder(
                                builder: (_) {
                                  final typeIndex = row * 2 + col;
                                  final type = BodyMetricType.values[typeIndex];
                                  final metric = latest[type];
                                  final valueLabel = metric != null
                                      ? '${metric.value} ${type.unit}'
                                      : '—';
                                  final dateLabel = metric != null
                                      ? dateFmt.format(metric.loggedAt)
                                      : null;
                                  return BodyMetricCard(
                                    label: type.label,
                                    valueLabel: valueLabel,
                                    dateLabel: dateLabel,
                                    icon:
                                        _icons[type] ??
                                        Icons.monitor_weight_outlined,
                                    onTap: () => _showLogSheet(type),
                                  );
                                },
                              ),
                            ),
                            if (col == 0) const SizedBox(width: 12),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                    const SizedBox(height: 8),
                    if (weightHistory.isNotEmpty) ...[
                      Text(
                        'BODYWEIGHT HISTORY',
                        style: TextStyle(
                          color: colors.text3,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...weightHistory.map(
                        (m) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  dateFmt.format(m.loggedAt),
                                  style: TextStyle(
                                    color: colors.text2,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              Text(
                                '${m.value} ${m.type.unit}',
                                style: TextStyle(
                                  color: colors.text1,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Semantics(
                                label: 'Delete entry',
                                button: true,
                                container: true,
                                child: GestureDetector(
                                  onTap: () => service.deleteEntry(m.id),
                                  child: Icon(
                                    Icons.close,
                                    color: colors.text3,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
