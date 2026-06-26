import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/models/workout_session.dart';

void main() {
  group('WorkoutSession', () {
    test('AC-001: SessionStatus resolves to and from its stored name (active, completed); an unknown name throws',
        () {
      expect(SessionStatus.active.name, 'active');
      expect(SessionStatus.values.byName('completed'), SessionStatus.completed);
      expect(() => SessionStatus.values.byName('paused'), throwsArgumentError);
    });

    test('AC-002: defaultSessionStatus is active (a newly started session is active)',
        () {
      expect(defaultSessionStatus, SessionStatus.active);
    });

    test('AC-003: sessionIsAbandoned is true when the session is completed and its total volume is zero',
        () {
      expect(
        sessionIsAbandoned(status: SessionStatus.completed, totalVolume: 0),
        isTrue,
      );
    });

    test('AC-004: sessionIsAbandoned is false for a completed session with positive volume',
        () {
      expect(
        sessionIsAbandoned(status: SessionStatus.completed, totalVolume: 4230),
        isFalse,
      );
    });

    test('AC-005: formatSessionDuration returns whole minutes under an hour (e.g. "47m") and "Hh Mm" at or above an hour',
        () {
      final start = DateTime(2026, 6, 23, 9, 0);
      expect(formatSessionDuration(start, start.add(const Duration(minutes: 47))), '47m');
      expect(
        formatSessionDuration(start, start.add(const Duration(hours: 1, minutes: 12))),
        '1h 12m',
      );
    });

    test('AC-006: formatSessionDuration returns "—" when the session has no completedAt',
        () {
      expect(formatSessionDuration(DateTime(2026, 6, 23, 9, 0), null), '—');
    });
  });
}
