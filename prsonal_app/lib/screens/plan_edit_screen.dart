import 'package:flutter/material.dart';
import '../widgets/brand_title.dart';
import '../widgets/app_button_widget.dart';
import '../widgets/app_modal_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/app_providers.dart';
import '../services/plans_service.dart';
import '../theme/app_colors.dart';
import '../widgets/day_of_week_selector_widget.dart';

class _EntryDraft {
  _EntryDraft({
    required this.routineId,
    required this.routineName,
    this.dayOfWeek,
  });

  final String routineId;
  final String routineName;
  int? dayOfWeek;
}

class PlanEditScreen extends ConsumerStatefulWidget {
  const PlanEditScreen({super.key, this.planId});

  final String? planId;

  @override
  ConsumerState<PlanEditScreen> createState() => _PlanEditScreenState();
}

class _PlanEditScreenState extends ConsumerState<PlanEditScreen> {
  final _nameCtrl = TextEditingController();
  bool _nameError = false;
  bool _initialized = false;
  List<_EntryDraft> _entries = [];

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  List<RoutineSummary> _cachedRoutines = [];

  void _addEntry() async {
    // Show routine picker — use the cached list pre-populated in build()
    final routines = _cachedRoutines;
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => ListView(
        children: routines.map((r) {
          return ListTile(
            title: Text(r.name),
            onTap: () {
              Navigator.of(ctx).pop();
              setState(() {
                _entries.add(
                  _EntryDraft(
                    routineId: r.id,
                    routineName: r.name,
                    dayOfWeek: null,
                  ),
                );
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Future<void> _save() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty) {
      setState(() => _nameError = true);
      return;
    }
    setState(() => _nameError = false);
    final service = ref.read(plansServiceProvider);
    final planId = widget.planId;
    if (planId == null) {
      final newId = await service.createPlan(name);
      await service.replaceEntries(
        newId,
        _entries
            .map(
              (e) => PlanEntryInput(
                routineId: e.routineId,
                dayOfWeek: e.dayOfWeek,
              ),
            )
            .toList(),
      );
    } else {
      await service.updatePlan(planId, name: name);
      await service.replaceEntries(
        planId,
        _entries
            .map(
              (e) => PlanEntryInput(
                routineId: e.routineId,
                dayOfWeek: e.dayOfWeek,
              ),
            )
            .toList(),
      );
    }
    if (mounted) await Navigator.of(context).maybePop();
  }

  Future<void> _deletePlan() async {
    final ok = await showConfirmSheet(
      context,
      title: 'Delete plan?',
      confirmLabel: 'Delete',
    );
    if (!ok) return;
    await ref.read(plansServiceProvider).deletePlan(widget.planId!);
    if (mounted) await Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;

    // Pre-watch routines so they're available when the picker sheet opens.
    _cachedRoutines = ref.watch(routinesListProvider).valueOrNull ?? [];

    // Load draft in edit mode
    if (widget.planId != null) {
      final draftAsync = ref.watch(planDraftProvider(widget.planId));
      if (!_initialized && draftAsync.hasValue && draftAsync.value != null) {
        final draft = draftAsync.value!;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!_initialized) {
            _initialized = true;
            _nameCtrl.text = draft.name;
            setState(() {
              _entries = draft.entries
                  .map(
                    (e) => _EntryDraft(
                      routineId: e.routineId,
                      routineName: e.routineName,
                      dayOfWeek: e.dayOfWeek,
                    ),
                  )
                  .toList();
            });
          }
        });
      }
    } else {
      _initialized = true;
    }

    return Scaffold(
      backgroundColor: colors.bg,
      appBar: AppBar(
        title: BrandTitle(widget.planId == null ? 'New Plan' : 'Edit Plan'),
        backgroundColor: colors.bg,
        actions: [
          IconButton(
            onPressed: _save,
            icon: const Icon(Icons.check),
            tooltip: 'Save',
            color: colors.accent,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: InputDecoration(
              labelText: 'Plan name',
              errorText: _nameError ? 'Plan name is required' : null,
            ),
            onChanged: (_) {
              if (_nameError) setState(() => _nameError = false);
            },
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Entries',
                style: TextStyle(
                  color: colors.text1,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              IconButton(
                onPressed: _addEntry,
                icon: const Icon(Icons.add),
                iconSize: 20,
                tooltip: 'Add entry',
                color: colors.accent,
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < _entries.length; i++) ...[
            _EntryRow(
              entry: _entries[i],
              onRemove: () => setState(() => _entries.removeAt(i)),
              onDayChanged: (day) =>
                  setState(() => _entries[i].dayOfWeek = day),
            ),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 16),
          if (widget.planId != null)
            AppButton(
              label: 'Delete plan',
              variant: AppButtonVariant.danger,
              onPressed: _deletePlan,
            ),
        ],
      ),
    );
  }
}

class _EntryRow extends StatelessWidget {
  const _EntryRow({
    required this.entry,
    required this.onRemove,
    required this.onDayChanged,
  });

  final _EntryDraft entry;
  final VoidCallback onRemove;
  final ValueChanged<int?> onDayChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface1,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  entry.routineName,
                  style: TextStyle(
                    color: colors.text1,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Tooltip(
                message: 'Remove entry',
                child: Semantics(
                  label: 'Remove entry',
                  button: true,
                  child: GestureDetector(
                    onTap: onRemove,
                    child: Icon(Icons.close, color: colors.text3, size: 18),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          DayOfWeekSelector(selected: entry.dayOfWeek, onChanged: onDayChanged),
        ],
      ),
    );
  }
}
