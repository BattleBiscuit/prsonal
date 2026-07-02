import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prsonal_app/services/platform_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('RealPlatformService', () {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

    tearDown(() {
      messenger.setMockMethodCallHandler(SystemChannels.platform, null);
    });

    test('AC-004: hapticTap/hapticPR/hapticSuccess invoke the platform channel '
        'with the correct, distinct impact type for each', () async {
      final invocations = <String?>[];
      messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          invocations.add(call.arguments as String?);
        }
        return null;
      });

      final service = RealPlatformService();
      await service.hapticTap();
      expect(invocations, ['HapticFeedbackType.lightImpact']);

      invocations.clear();
      await service.hapticPR();
      expect(invocations, [
        'HapticFeedbackType.heavyImpact',
        'HapticFeedbackType.heavyImpact',
      ]);

      invocations.clear();
      await service.hapticSuccess();
      expect(invocations, ['HapticFeedbackType.mediumImpact']);
    });

    test('AC-005: every method completes without throwing when the underlying '
        'platform channel is unavailable', () async {
      // No mock handler registered — flutter_test's default binding throws
      // MissingPluginException for every channel, exactly like running on
      // a platform without haptics/notifications/wakelock support.
      final service = RealPlatformService();
      await expectLater(service.hapticTap(), completes);
      await expectLater(service.hapticPR(), completes);
      await expectLater(service.hapticSuccess(), completes);
      await expectLater(
        service.scheduleRestComplete(const Duration(seconds: 1)),
        completes,
      );
      await expectLater(service.cancelRestComplete(), completes);
      await expectLater(service.enableSessionWakelock(), completes);
      await expectLater(service.disableSessionWakelock(), completes);
    });
  });

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
