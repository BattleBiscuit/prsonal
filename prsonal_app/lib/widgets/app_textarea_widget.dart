import 'package:flutter/material.dart';
import 'package:prsonal_app/theme/app_colors.dart';

class AppTextarea extends StatelessWidget {
  const AppTextarea({
    super.key,
    this.label,
    this.rows = 4,
    this.onChanged,
    this.enabled = true,
    this.controller,
    this.placeholder,
    this.initialValue,
  });

  final String? label;
  final int rows;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final TextEditingController? controller;
  final String? placeholder;
  final String? initialValue;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>() ?? AppColors.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              color: colors.text2,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
        ],
        TextField(
          controller: controller,
          enabled: enabled,
          onChanged: onChanged,
          maxLines: rows,
          style: TextStyle(color: colors.text1),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: colors.text3),
            filled: true,
            fillColor: colors.surface2,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: colors.borderFocus),
            ),
          ),
        ),
      ],
    );
  }
}
