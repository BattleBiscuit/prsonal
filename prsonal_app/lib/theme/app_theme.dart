import 'package:flutter/material.dart';
import 'package:prsonal_app/theme/app_colors.dart';

/// The single Material 3 dark [ThemeData] for prsonal_app.
///
/// Apply with `MaterialApp(theme: appTheme)`.
final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: const ColorScheme.dark(
    // ColorScheme slot → design-system token → hex
    primary: Color(0xFFE8FF47), // accent
    onPrimary: Color(0xFF0F0F0F), // hardcoded dark
    surface: Color(0xFF0F0F0F), // bg
    onSurface: Color(0xFFF5F5F5), // text-1
    surfaceContainer: Color(0xFF1A1A1A), // surface-1
    surfaceContainerHigh: Color(0xFF242424), // surface-2
    surfaceContainerHighest: Color(0xFF2E2E2E), // surface-3
    onSurfaceVariant: Color(0xFF9E9E9E), // text-2
    outline: Color(0xFF2E2E2E), // border
    error: Color(0xFFF44336), // danger
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF0F0F0F), // bg
    foregroundColor: Color(0xFFF5F5F5), // text-1
    elevation: 0,
    scrolledUnderElevation: 0,
    surfaceTintColor: Colors.transparent,
    shape: Border(
      bottom: BorderSide(color: Color(0xFF2E2E2E), width: 1), // border
    ),
  ),
  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: const Color(0xFF1A1A1A), // surface-1
    indicatorColor: Colors.transparent, // no pill; gym-app tints the icon/label only
    surfaceTintColor: Colors.transparent,
    labelTextStyle: WidgetStateProperty.resolveWith(
      (states) => TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: states.contains(WidgetState.selected)
            ? const Color(0xFFE8FF47) // accent
            : const Color(0xFF616161), // text-3
      ),
    ),
    iconTheme: WidgetStateProperty.resolveWith(
      (states) => IconThemeData(
        size: 22,
        color: states.contains(WidgetState.selected)
            ? const Color(0xFFE8FF47) // accent
            : const Color(0xFF616161), // text-3
      ),
    ),
  ),
  textTheme: const TextTheme(
    // token → size : TextTheme slot (approx mapping from design_system.md)
    displaySmall: TextStyle(fontSize: 30, fontWeight: FontWeight.w700), // 3xl
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700), // 2xl
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700), // xl
    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600), // lg
    bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5), // base
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400), // sm
    bodySmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w400), // sm
    labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400), // xs
  ),
  extensions: const [
    AppColors.dark,
  ],
);
