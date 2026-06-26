// Motion tokens from the design system. Centralized so animations stay
// consistent instead of hard-coding magic durations per widget.

class AppDurations {
  AppDurations._();

  /// Quick state changes (taps, toggles).
  static const Duration fast = Duration(milliseconds: 120);

  /// Standard transitions (sheets, fades).
  static const Duration normal = Duration(milliseconds: 200);

  /// Deliberate fills (progress bars, rest ring).
  static const Duration slow = Duration(milliseconds: 400);
}
