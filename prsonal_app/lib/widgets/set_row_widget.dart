import 'package:flutter/material.dart';
import 'package:prsonal_app/models/exercise.dart';
import 'package:prsonal_app/services/session_service.dart' show ActiveSetStatus;
import 'package:prsonal_app/theme/app_colors.dart';
import 'package:prsonal_app/theme/app_spacing.dart';

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
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text(
                '${widget.index + 1}',
                style: TextStyle(
                  color: colors.text3,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 12),
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
    // Tier 3 — polarity inversion. The live set is the single loudest element
    // in the session: a solid chalk (accent) block with deep-dark (onAccent)
    // content, flipping the dark-on-light system rule so it snaps out from the
    // Tier 2 logs around it. (Design system: Visual tiering architecture.)
    return Container(
      color: colors.accent,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '${widget.index + 1}',
              style: TextStyle(
                color: colors.onAccent,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildInvertedField(
              colors,
              controller: _primaryController,
              hint: 'Reps',
              onChanged: widget.onPrimaryChanged,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildInvertedField(
              colors,
              controller: _secondaryController,
              hint: 'kg',
              onChanged: widget.onSecondaryChanged,
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            label: 'Complete set',
            button: true,
            child: GestureDetector(
              onTap: widget.onToggleComplete,
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: Icon(
                    Icons.check_box_outline_blank,
                    color: colors.onAccent,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Input styled for the inverted (chalk) surface: dark text on chalk, with a
  // discoverable dark contour even when un-focused (high-glare safeguard) that
  // resolves to a solid dark border on focus.
  Widget _buildInvertedField(
    AppColors colors, {
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      onChanged: onChanged,
      cursorColor: colors.onAccent,
      style: TextStyle(color: colors.onAccent, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: colors.onAccent.withValues(alpha: 0.45)),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: colors.onAccent.withValues(alpha: 0.30)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: colors.onAccent, width: 2),
        ),
      ),
    );
  }

  Widget _buildCompleted(BuildContext context, AppColors colors) {
    return Opacity(
      opacity: 0.65,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text(
                '${widget.index + 1}',
                style: TextStyle(
                  color: colors.success,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.actualLabel ?? widget.plannedLabel,
                style: TextStyle(color: colors.success, fontSize: 14),
              ),
            ),
            if (widget.isPR)
              Semantics(
                label: 'Personal record',
                container: true,
                child: ExcludeSemantics(
                  child: Icon(
                    Icons.emoji_events,
                    color: colors.warning,
                    size: 18,
                  ),
                ),
              ),
            const SizedBox(width: 8),
            Icon(Icons.check_box, color: colors.success, size: 22),
          ],
        ),
      ),
    );
  }

  Widget _buildSkipped(BuildContext context, AppColors colors) {
    return Opacity(
      opacity: 0.35,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            SizedBox(
              width: 32,
              child: Text(
                '${widget.index + 1}',
                style: TextStyle(
                  color: colors.text3,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 12),
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
      ),
    );
  }
}
