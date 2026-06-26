import 'package:flutter/material.dart';

/// AppColors — a [ThemeExtension] carrying design-system tokens that don't
/// fit cleanly into [ColorScheme]: the surface ladder, text tiers,
/// accent-dim, and semantic colours.
///
/// Access via `Theme.of(context).extension<AppColors>()!`.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.bg,
    required this.surface1,
    required this.surface2,
    required this.surface3,
    required this.accent,
    required this.accentDim,
    required this.onAccent,
    required this.text1,
    required this.text2,
    required this.text3,
    required this.border,
    required this.borderFocus,
    required this.success,
    required this.danger,
    required this.warning,
  });

  final Color bg;
  final Color surface1;
  final Color surface2;
  final Color surface3;
  final Color accent;
  final Color accentDim;
  final Color onAccent;
  final Color text1;
  final Color text2;
  final Color text3;
  final Color border;
  final Color borderFocus;
  final Color success;
  final Color danger;
  final Color warning;

  /// The canonical dark token set ported from gym-app's CSS design tokens.
  static const AppColors dark = AppColors(
    bg: Color(0xFF0F0F0F),
    surface1: Color(0xFF1A1A1A),
    surface2: Color(0xFF242424),
    surface3: Color(0xFF2E2E2E),
    accent: Color(0xFFE8FF47),
    accentDim: Color(0xFFB8CC35),
    onAccent: Color(0xFF0F0F0F),
    text1: Color(0xFFF5F5F5),
    text2: Color(0xFF9E9E9E),
    text3: Color(0xFF616161),
    border: Color(0xFF2E2E2E),
    borderFocus: Color(0xFFE8FF47),
    success: Color(0xFF4CAF50),
    danger: Color(0xFFF44336),
    warning: Color(0xFFFF9800),
  );

  @override
  AppColors copyWith({
    Color? bg,
    Color? surface1,
    Color? surface2,
    Color? surface3,
    Color? accent,
    Color? accentDim,
    Color? onAccent,
    Color? text1,
    Color? text2,
    Color? text3,
    Color? border,
    Color? borderFocus,
    Color? success,
    Color? danger,
    Color? warning,
  }) {
    return AppColors(
      bg: bg ?? this.bg,
      surface1: surface1 ?? this.surface1,
      surface2: surface2 ?? this.surface2,
      surface3: surface3 ?? this.surface3,
      accent: accent ?? this.accent,
      accentDim: accentDim ?? this.accentDim,
      onAccent: onAccent ?? this.onAccent,
      text1: text1 ?? this.text1,
      text2: text2 ?? this.text2,
      text3: text3 ?? this.text3,
      border: border ?? this.border,
      borderFocus: borderFocus ?? this.borderFocus,
      success: success ?? this.success,
      danger: danger ?? this.danger,
      warning: warning ?? this.warning,
    );
  }

  @override
  AppColors lerp(AppColors? other, double t) {
    if (other == null) return this;
    return AppColors(
      bg: Color.lerp(bg, other.bg, t)!,
      surface1: Color.lerp(surface1, other.surface1, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      surface3: Color.lerp(surface3, other.surface3, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentDim: Color.lerp(accentDim, other.accentDim, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      text1: Color.lerp(text1, other.text1, t)!,
      text2: Color.lerp(text2, other.text2, t)!,
      text3: Color.lerp(text3, other.text3, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderFocus: Color.lerp(borderFocus, other.borderFocus, t)!,
      success: Color.lerp(success, other.success, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
    );
  }
}
