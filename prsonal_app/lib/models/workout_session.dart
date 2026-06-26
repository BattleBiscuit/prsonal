// WorkoutSession model — pure Dart, no Flutter/Drift imports.

enum SessionStatus { active, completed }

/// The status assigned to a newly started session.
const SessionStatus defaultSessionStatus = SessionStatus.active;

/// Returns true when [status] is completed and [totalVolume] is zero —
/// indicating the session was abandoned without completing any sets.
bool sessionIsAbandoned({
  required SessionStatus status,
  required double totalVolume,
}) {
  return status == SessionStatus.completed && totalVolume == 0;
}

/// Formats the elapsed time between [startedAt] and [completedAt].
///
/// Returns "—" when [completedAt] is null.
/// Returns "Hh Mm" for durations of an hour or more.
/// Returns "Mm" for durations under an hour.
String formatSessionDuration(DateTime startedAt, DateTime? completedAt) {
  if (completedAt == null) return '—';
  final diff = completedAt.difference(startedAt);
  final totalMinutes = diff.inMinutes;
  if (totalMinutes >= 60) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    return '${hours}h ${minutes}m';
  }
  return '${totalMinutes}m';
}
