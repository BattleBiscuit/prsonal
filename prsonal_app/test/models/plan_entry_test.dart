import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/models/plan_entry.dart';

void main() {
  group('PlanEntry', () {
    test(
      'AC-001: dayOfWeekLabel returns the three-letter weekday for 0–6 as Mon, Tue, Wed, Thu, Fri, Sat, Sun',
      () {
        expect(
          [for (var d = 0; d <= 6; d++) dayOfWeekLabel(d)],
          ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
        );
      },
    );

    test(
      'AC-002: dayOfWeekLabel returns "·" when dayOfWeek is null (unscheduled)',
      () {
        expect(dayOfWeekLabel(null), '·');
      },
    );

    test(
      'AC-003: validateDayOfWeek accepts null and integers 0 through 6 and rejects any value outside that range',
      () {
        expect(validateDayOfWeek(null), isTrue);
        expect(validateDayOfWeek(0), isTrue);
        expect(validateDayOfWeek(6), isTrue);
        expect(validateDayOfWeek(-1), isFalse);
        expect(validateDayOfWeek(7), isFalse);
      },
    );
  });
}
