import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/models/plan.dart';

void main() {
  group('Plan', () {
    test(
      'AC-001: PlanStatus resolves to and from its stored name (active, archived); an unknown name throws',
      () {
        expect(PlanStatus.active.name, 'active');
        expect(PlanStatus.values.byName('archived'), PlanStatus.archived);
        expect(() => PlanStatus.values.byName('paused'), throwsArgumentError);
      },
    );

    test(
      'AC-002: validatePlanName returns false for an empty or whitespace-only name and true otherwise',
      () {
        expect(validatePlanName(''), isFalse);
        expect(validatePlanName('   '), isFalse);
        expect(validatePlanName('PPL 6-day'), isTrue);
      },
    );

    test(
      'AC-003: defaultPlanStatus is active (a newly created plan is active)',
      () {
        expect(defaultPlanStatus, PlanStatus.active);
      },
    );
  });
}
