// PlanEntry model — pure Dart, no Flutter/Drift imports.

/// Maps day index (0=Mon … 6=Sun) to a three-letter label.
/// Returns "·" when [dayOfWeek] is null (unscheduled).
String dayOfWeekLabel(int? dayOfWeek) {
  if (dayOfWeek == null) return '·';
  const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  return labels[dayOfWeek];
}

/// Returns true when [dayOfWeek] is null or an integer in the range 0–6.
bool validateDayOfWeek(int? dayOfWeek) {
  if (dayOfWeek == null) return true;
  return dayOfWeek >= 0 && dayOfWeek <= 6;
}
