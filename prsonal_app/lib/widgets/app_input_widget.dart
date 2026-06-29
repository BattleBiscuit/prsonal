import 'package:flutter/material.dart';
import 'package:prsonal_app/theme/app_colors.dart';

class AppInput extends StatelessWidget {
  const AppInput({
    super.key,
    this.label,
    this.placeholder,
    this.onChanged,
    this.errorText,
    this.enabled = true,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.initialValue,
  });

  final String? label;
  final String? placeholder;
  final ValueChanged<String>? onChanged;
  final String? errorText;
  final bool enabled;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
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
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: TextStyle(color: colors.text1),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: colors.text3),
            errorText: errorText,
            filled: true,
            fillColor: colors.surface2,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: colors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: colors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: colors.borderFocus),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.zero,
              borderSide: BorderSide(color: colors.border),
            ),
          ),
        ),
      ],
    );
  }
}
