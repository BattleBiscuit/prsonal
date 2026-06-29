import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/services/platform_service.dart';

void main() {
  group('PlatformService (fake)', () {
    test(
      'AC-001: FakePlatformService records hapticTap, hapticPR and hapticSuccess calls',
      () async {
        final fake = FakePlatformService();
        await fake.hapticTap();
        await fake.hapticPR();
        await fake.hapticSuccess();
        expect(fake.hapticLog, ['tap', 'pr', 'success']);
      },
    );

    test(
      'AC-002: scheduleRestComplete records the requested duration and cancelRestComplete clears the pending rest notification',
      () async {
        final fake = FakePlatformService();
        await fake.scheduleRestComplete(const Duration(seconds: 90));
        expect(fake.pendingRest, const Duration(seconds: 90));
        await fake.cancelRestComplete();
        expect(fake.pendingRest, isNull);
      },
    );

    test(
      'AC-003: enableSessionWakelock and disableSessionWakelock toggle a recorded wakelock flag',
      () async {
        final fake = FakePlatformService();
        await fake.enableSessionWakelock();
        expect(fake.wakelockEnabled, isTrue);
        await fake.disableSessionWakelock();
        expect(fake.wakelockEnabled, isFalse);
      },
    );
  });
}
