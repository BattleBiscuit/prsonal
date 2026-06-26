import 'package:flutter/material.dart';
import 'package:prsonal_app/models/exercise.dart';
import 'package:prsonal_app/theme/app_colors.dart';

@immutable
class SetTableRow {
  const SetTableRow({
    this.id = '',
    required this.setIndex,
    required this.plannedLabel,
    this.actualLabel,
    required this.skipped,
    required this.isPR,
    required this.kind,
    this.primaryValue,
    this.secondaryValue,
  });

  /// The database id of the underlying workout set. Used by history screens
  /// to persist edits. Defaults to empty string for display-only contexts.
  final String id;
  final int setIndex;
  final String plannedLabel;
  final String? actualLabel;
  final bool skipped;
  final bool isPR;
  final ExerciseType kind;
  final String? primaryValue;
  final String? secondaryValue;
}

class HistorySetTable extends StatelessWidget {
  const HistorySetTable({
    super.key,
    required this.exerciseName,
    required this.rows,
    this.editing = false,
  });

  final String exerciseName;
  final List<SetTableRow> rows;
  final bool editing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            exerciseName,
            style: TextStyle(color: colors.text1, fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
        ...rows.map((row) => _SetRow(row: row, editing: editing, colors: colors)),
      ],
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({required this.row, required this.editing, required this.colors});
  final SetTableRow row;
  final bool editing;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text('${row.setIndex + 1}', style: TextStyle(color: colors.text3, fontSize: 13)),
          ),
          Expanded(
            child: Text(row.plannedLabel, style: TextStyle(color: colors.text2, fontSize: 13)),
          ),
          if (row.isPR)
            Semantics(
              label: 'Personal record',
              container: true,
              excludeSemantics: true,
              child: Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text('PR', style: TextStyle(color: colors.accent, fontSize: 10, fontWeight: FontWeight.w700)),
              ),
            ),
          if (row.skipped)
            Text('Skip', style: TextStyle(color: colors.text3, fontSize: 13))
          else if (editing)
            SizedBox(
              width: 80,
              child: TextField(
                controller: TextEditingController(text: row.actualLabel ?? ''),
                style: TextStyle(color: colors.text1, fontSize: 13),
                decoration: InputDecoration(
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                ),
              ),
            )
          else
            Text(row.actualLabel ?? '—', style: TextStyle(color: colors.text1, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
