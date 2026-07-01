import 'package:flutter/material.dart';
import 'package:prsonal_app/models/exercise.dart';
import 'package:prsonal_app/services/session_service.dart' show ActiveSetStatus;
import 'package:prsonal_app/theme/app_colors.dart';
import 'package:prsonal_app/theme/app_spacing.dart';
import 'package:prsonal_app/theme/app_typography.dart';

class SetRow extends StatefulWidget {
  const SetRow({
    super.key,
    required this.index,
    required this.kind,
    required this.status,
    required this.plannedLabel,
    this.actualLabel,
    this.isPR = false,
    this.isBodyweight = false,
    this.primaryValue,
    this.secondaryValue,
    this.onPrimaryChanged,
    this.onSecondaryChanged,
    this.onToggleBodyweight,
    this.onToggleComplete,
    this.onSelect,
  });

  final int index;
  final ExerciseType kind;
  final ActiveSetStatus status;
  final String plannedLabel;
  final String? actualLabel;
  final bool isPR;
  final bool isBodyweight;
  final String? primaryValue;
  final String? secondaryValue;
  final ValueChanged<String>? onPrimaryChanged;
  final ValueChanged<String>? onSecondaryChanged;
  final VoidCallback? onToggleBodyweight;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onSelect;

  @override
  State<SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<SetRow> {
  late final TextEditingController _primaryController;
  late final TextEditingController _secondaryController;

  @override
  void initState() {
    super.initState();
    _primaryController = TextEditingController(text: widget.primaryValue ?? '');
    _secondaryController = TextEditingController(
      text: widget.secondaryValue ?? '',
    );
  }

  @override
  void didUpdateWidget(SetRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync controllers only when the externally provided value actually changes
    // and differs from what the user has typed — keeps the caret stable while
    // typing, but re-seeds when the active set switches.
    _syncController(_primaryController, widget.primaryValue);
    _syncController(_secondaryController, widget.secondaryValue);
  }

  void _syncController(TextEditingController controller, String? value) {
    final next = value ?? '';
    if (controller.text != next) {
      controller.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: next.length),
      );
    }
  }

  @override
  void dispose() {
    _primaryController.dispose();
    _secondaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;

    switch (widget.status) {
      case ActiveSetStatus.upcoming:
      case ActiveSetStatus.pending:
        return _buildUpcoming(context, colors);
      case ActiveSetStatus.active:
        return _buildActive(context, colors);
      case ActiveSetStatus.completed:
        return _buildCompleted(context, colors);
      case ActiveSetStatus.skipped:
        return _buildSkipped(context, colors);
    }
  }

  Widget _buildUpcoming(BuildContext context, AppColors colors) {
    return GestureDetector(
      onTap: widget.onSelect,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: space2, horizontal: 4),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text(
                '${widget.index + 1}',
                style: monoNumerals(
                  TextStyle(
                    color: colors.text3,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: space3),
            Text(
              widget.plannedLabel,
              style: TextStyle(color: colors.text2, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActive(BuildContext context, AppColors colors) {
    // Tier 3 — live "you are here" row. Rather than a solid chalk block, the
    // active set is a faint accent tint with a 2px accent left rail and light
    // (text1) content, so it reads as the live focus without glaring. The input
    // and checkbox borders are a thicker dim-grey contour (accent @ 30%) — never
    // a bright white outline. (Design system: Visual tiering architecture.)
    final fieldBorder = colors.accent.withValues(alpha: 0.30);
    return Container(
      decoration: BoxDecoration(
        color: colors.accent.withValues(alpha: 0.06),
        border: Border(left: BorderSide(color: colors.accent, width: 2)),
      ),
      padding: const EdgeInsets.symmetric(vertical: space2, horizontal: 12),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '${widget.index + 1}',
              style: monoNumerals(
                TextStyle(
                  color: colors.text1,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: space2),
          Expanded(
            child: _buildField(
              colors,
              controller: _primaryController,
              hint: 'Reps',
              onChanged: widget.onPrimaryChanged,
              border: fieldBorder,
            ),
          ),
          const SizedBox(width: space2),
          _buildBodyweightToggle(colors),
          const SizedBox(width: space2),
          Expanded(
            child: _buildField(
              colors,
              controller: _secondaryController,
              hint: widget.isBodyweight ? '±kg' : 'kg',
              onChanged: widget.onSecondaryChanged,
              border: fieldBorder,
              signed: widget.isBodyweight,
            ),
          ),
          const SizedBox(width: space2),
          Semantics(
            label: 'Complete set',
            button: true,
            child: GestureDetector(
              onTap: widget.onToggleComplete,
              child: SizedBox(
                width: touchTargetMin,
                height: touchTargetMin,
                child: Center(
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      border: Border.all(color: fieldBorder, width: 2),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Bodyweight pill toggle: flips the set to bodyweight-relative. Off reads as a
  // neutral surface3 pill; on is the accent-filled toggle (onAccent label), per
  // the design system's pill-toggle rule.
  Widget _buildBodyweightToggle(AppColors colors) {
    final on = widget.isBodyweight;
    return Semantics(
      label: 'Bodyweight',
      button: true,
      toggled: on,
      container: true,
      onTap: widget.onToggleBodyweight,
      child: ExcludeSemantics(
        child: GestureDetector(
          onTap: widget.onToggleBodyweight,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: space2,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: on ? colors.accent : colors.surface3,
              borderRadius: BorderRadius.circular(radiusFull),
            ),
            child: Text(
              'BW',
              style: TextStyle(
                color: on ? colors.onAccent : colors.text2,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Live-row input: light (text1) text on the dark tint, with a thicker
  // dim-grey contour (accent @ 30%) that stays the same on focus — a firmer
  // edge for high-glare gyms, never a bright white outline. [signed] allows a
  // leading minus for assisted bodyweight sets.
  Widget _buildField(
    AppColors colors, {
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String>? onChanged,
    required Color border,
    bool signed = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(
        decimal: true,
        signed: signed,
      ),
      onChanged: onChanged,
      cursorColor: colors.text1,
      style: monoNumerals(TextStyle(color: colors.text1, fontSize: 14)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: colors.text1.withValues(alpha: 0.45)),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: space2,
          vertical: 8,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: border, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: border, width: 2),
        ),
      ),
    );
  }

  Widget _buildCompleted(BuildContext context, AppColors colors) {
    // Read-only log. The logged values are the data you review, so they stay at
    // full strength in primary text1 (no blanket dimming). Colour marks the
    // event, not the readout: success on the checked box, and a warning PR star.
    // Tapping the row re-opens the set for editing (onSelect).
    return GestureDetector(
      onTap: widget.onSelect,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: space2, horizontal: 4),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text(
                '${widget.index + 1}',
                style: monoNumerals(
                  TextStyle(
                    color: colors.text3,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: space3),
            Expanded(
              child: Text(
                widget.actualLabel ?? widget.plannedLabel,
                style: TextStyle(color: colors.text1, fontSize: 14),
              ),
            ),
            if (widget.isPR)
              Semantics(
                label: 'Personal record',
                container: true,
                child: ExcludeSemantics(
                  child: Icon(
                    Icons.star_outline,
                    color: colors.warning,
                    size: 18,
                  ),
                ),
              ),
            const SizedBox(width: space2),
            Icon(Icons.check_box_outlined, color: colors.success, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipped(BuildContext context, AppColors colors) {
    // Least-relevant state. Struck-through planned label in tertiary text plus a
    // readable "Skip" badge — clearly "not done" without dropping to an
    // unreadable blanket fade.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: space2, horizontal: 4),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '${widget.index + 1}',
              style: monoNumerals(
                TextStyle(
                  color: colors.text3,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: space3),
          Expanded(
            child: Text(
              widget.plannedLabel,
              style: TextStyle(
                color: colors.text3,
                fontSize: 14,
                decoration: TextDecoration.lineThrough,
                decorationColor: colors.text3,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 8),
            decoration: BoxDecoration(
              color: colors.surface3,
              borderRadius: BorderRadius.circular(radiusFull),
            ),
            child: Text(
              'Skip',
              style: TextStyle(
                color: colors.text2,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
