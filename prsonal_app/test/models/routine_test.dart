import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/models/routine.dart';

void main() {
  group('Routine', () {
    test('AC-001: validateRoutineName returns false for an empty or whitespace-only name and true otherwise',
        () {
      expect(validateRoutineName(''), isFalse);
      expect(validateRoutineName('   '), isFalse);
      expect(validateRoutineName('Push Day A'), isTrue);
    });

    test('AC-002: exerciseCountLabel returns "1 exercise" for a count of one and "N exercises" for any other count',
        () {
      expect(exerciseCountLabel(0), '0 exercises');
      expect(exerciseCountLabel(1), '1 exercise');
      expect(exerciseCountLabel(3), '3 exercises');
    });
  });
}
