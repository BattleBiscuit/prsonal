import 'package:flutter/material.dart';
import 'package:prsonal_app/theme/app_colors.dart';

// Token shortcuts (kept local so the ColorScheme/component themes read cleanly).
const _bg = Color(0xFF0F0F0F);
const _surface1 = Color(0xFF1A1A1A);
const _surface2 = Color(0xFF242424);
const _surface3 = Color(0xFF2E2E2E);
const _accent = Color(0xFFEDEDED);
const _onAccent = Color(0xFF0F0F0F);
const _text1 = Color(0xFFF5F5F5);
const _text2 = Color(0xFF9E9E9E);
const _text3 = Color(0xFF616161);
const _danger = Color(0xFFF44336);

/// The single Material 3 dark [ThemeData] for prsonal_app.
///
/// The ColorScheme is fully specified — every slot maps to a brand token — so
/// Material components never fall back to default teal/purple. Component themes
/// below align the stock widgets (inputs, chips, sliders, sheets, dialogs, FAB,
/// text selection) with the design system; custom AppX widgets read [AppColors].
///
/// Apply with `MaterialApp(theme: appTheme)`.
final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: _bg,
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: _accent,
    onPrimary: _onAccent,
    primaryContainer: _surface2,
    onPrimaryContainer: _accent,
    // Single-accent system: secondary/tertiary mirror the accent, their
    // containers are neutral surfaces so chips/toggles never render teal.
    secondary: _accent,
    onSecondary: _onAccent,
    secondaryContainer: _surface2,
    onSecondaryContainer: _text1,
    tertiary: _accent,
    onTertiary: _onAccent,
    tertiaryContainer: _surface2,
    onTertiaryContainer: _text1,
    error: _danger,
    onError: _text1,
    errorContainer: Color(0xFF2A0A0A),
    onErrorContainer: Color(0xFFFF6B6B),
    surface: _bg,
    onSurface: _text1,
    surfaceDim: _bg,
    surfaceBright: _surface3,
    surfaceContainerLowest: Color(0xFF0A0A0A),
    surfaceContainerLow: Color(0xFF141414),
    surfaceContainer: _surface1,
    surfaceContainerHigh: _surface2,
    surfaceContainerHighest: _surface3,
    onSurfaceVariant: _text2,
    outline: _surface3,
    outlineVariant: _surface3,
    inverseSurface: _text1,
    onInverseSurface: _bg,
    inversePrimary: _accent,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
  ),

  // List rows are flat (no card chrome); a 1px hairline in the border token
  // (#2E2E2E) separates them. A bare `Divider()` picks this up everywhere.
  dividerTheme: const DividerThemeData(
    color: _surface3,
    thickness: 1,
    space: 1,
  ),

  appBarTheme: const AppBarTheme(
    backgroundColor: _bg,
    foregroundColor: _text1,
    elevation: 0,
    scrolledUnderElevation: 0,
    surfaceTintColor: Colors.transparent,
    shape: Border(bottom: BorderSide(color: _surface3, width: 1)),
  ),

  navigationBarTheme: NavigationBarThemeData(
    backgroundColor: _surface1,
    indicatorColor: Colors.transparent, // gym-app tints the icon/label, no pill
    surfaceTintColor: Colors.transparent,
    labelTextStyle: WidgetStateProperty.resolveWith(
      (s) => TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: s.contains(WidgetState.selected) ? _accent : _text3,
      ),
    ),
    iconTheme: WidgetStateProperty.resolveWith(
      (s) => IconThemeData(
        size: 22,
        color: s.contains(WidgetState.selected) ? _accent : _text3,
      ),
    ),
  ),

  // Inputs: surface-2 fill, no resting border, 2px accent focus, danger error.
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: _surface2,
    hintStyle: const TextStyle(color: _text3),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _accent, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _danger, width: 2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: _danger, width: 2),
    ),
  ),

  dialogTheme: const DialogThemeData(
    backgroundColor: _surface1,
    surfaceTintColor: Colors.transparent,
    titleTextStyle: TextStyle(
      color: _text1,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    ),
    contentTextStyle: TextStyle(color: _text2, fontSize: 14),
  ),

  bottomSheetTheme: const BottomSheetThemeData(
    backgroundColor: _surface1,
    surfaceTintColor: Colors.transparent,
    modalBackgroundColor: _surface1,
    showDragHandle: false,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
  ),

  chipTheme: ChipThemeData(
    backgroundColor: _surface2,
    selectedColor: _accent,
    secondarySelectedColor: _accent,
    checkmarkColor: _onAccent,
    labelStyle: const TextStyle(color: _text2, fontSize: 12),
    secondaryLabelStyle: const TextStyle(color: _onAccent, fontSize: 12),
    side: const BorderSide(color: _surface3),
    shape: const StadiumBorder(),
  ),

  sliderTheme: const SliderThemeData(
    activeTrackColor: _accent,
    inactiveTrackColor: _surface3,
    thumbColor: _accent,
    overlayColor: Color(0x33EDEDED),
  ),

  switchTheme: SwitchThemeData(
    thumbColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.selected) ? _onAccent : _text2,
    ),
    trackColor: WidgetStateProperty.resolveWith(
      (s) => s.contains(WidgetState.selected) ? _accent : _surface3,
    ),
    trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
  ),

  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: _accent,
    foregroundColor: _onAccent,
  ),

  snackBarTheme: const SnackBarThemeData(
    backgroundColor: _surface2,
    contentTextStyle: TextStyle(color: _text1),
    actionTextColor: _accent,
    behavior: SnackBarBehavior.floating,
  ),

  textSelectionTheme: const TextSelectionThemeData(
    cursorColor: _accent,
    selectionColor: Color(0x4DEDEDED),
    selectionHandleColor: _accent,
  ),

  textTheme: const TextTheme(
    displaySmall: TextStyle(fontSize: 30, fontWeight: FontWeight.w700), // 3xl
    headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w700), // 2xl
    titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w700), // xl
    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600), // lg
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 1.5,
    ), // base
    bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400), // sm
    bodySmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w400), // sm
    labelSmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400), // xs
  ),

  extensions: const [AppColors.dark],
);
