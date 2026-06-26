// Routine model — pure Dart, no Flutter/Drift imports.

/// Returns true when [name] is non-empty after trimming whitespace.
bool validateRoutineName(String name) => name.trim().isNotEmpty;

/// Returns "1 exercise" for a count of one, "N exercises" otherwise.
String exerciseCountLabel(int count) {
  if (count == 1) return '1 exercise';
  return '$count exercises';
}
