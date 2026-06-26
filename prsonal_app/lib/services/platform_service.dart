import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

// ---------------------------------------------------------------------------
// Abstract interface
// ---------------------------------------------------------------------------

abstract class PlatformService {
  Future<void> hapticTap();
  Future<void> hapticPR();
  Future<void> hapticSuccess();
  Future<void> scheduleRestComplete(Duration after);
  Future<void> cancelRestComplete();
  Future<void> enableSessionWakelock();
  Future<void> disableSessionWakelock();
}

// ---------------------------------------------------------------------------
// Real implementation
// ---------------------------------------------------------------------------

class RealPlatformService implements PlatformService {
  static const int _restNotificationId = 1;
  static const String _notificationChannelId = 'prsonal_rest';
  static const String _notificationChannelName = 'Rest Timer';

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool _notificationsInitialised = false;
  Timer? _restTimer;

  Future<void> _ensureNotificationsInitialised() async {
    if (_notificationsInitialised) return;
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );
    await _notifications.initialize(initSettings);
    _notificationsInitialised = true;
  }

  @override
  Future<void> hapticTap() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (_) {}
  }

  @override
  Future<void> hapticPR() async {
    try {
      await HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      await HapticFeedback.heavyImpact();
    } catch (_) {}
  }

  @override
  Future<void> hapticSuccess() async {
    try {
      await HapticFeedback.mediumImpact();
    } catch (_) {}
  }

  @override
  Future<void> scheduleRestComplete(Duration after) async {
    try {
      _restTimer?.cancel();
      await _ensureNotificationsInitialised();
      const androidDetails = AndroidNotificationDetails(
        _notificationChannelId,
        _notificationChannelName,
        importance: Importance.high,
        priority: Priority.high,
      );
      const details = NotificationDetails(android: androidDetails);
      // Use a delayed timer to fire the notification at the right time.
      // This approach avoids the timezone dependency required by zonedSchedule.
      _restTimer = Timer(after, () async {
        try {
          await _notifications.show(
            _restNotificationId,
            'Rest complete',
            'Rest complete — time to hit the next set \u{1F4AA}',
            details,
          );
        } catch (_) {}
      });
    } catch (_) {}
  }

  @override
  Future<void> cancelRestComplete() async {
    try {
      _restTimer?.cancel();
      _restTimer = null;
      await _ensureNotificationsInitialised();
      await _notifications.cancel(_restNotificationId);
    } catch (_) {}
  }

  @override
  Future<void> enableSessionWakelock() async {
    try {
      await WakelockPlus.enable();
    } catch (_) {}
  }

  @override
  Future<void> disableSessionWakelock() async {
    try {
      await WakelockPlus.disable();
    } catch (_) {}
  }
}

// ---------------------------------------------------------------------------
// Fake implementation (for tests)
// ---------------------------------------------------------------------------

class FakePlatformService implements PlatformService {
  final List<String> hapticLog = [];
  Duration? pendingRest;
  bool wakelockEnabled = false;

  @override
  Future<void> hapticTap() async => hapticLog.add('tap');

  @override
  Future<void> hapticPR() async => hapticLog.add('pr');

  @override
  Future<void> hapticSuccess() async => hapticLog.add('success');

  @override
  Future<void> scheduleRestComplete(Duration after) async =>
      pendingRest = after;

  @override
  Future<void> cancelRestComplete() async => pendingRest = null;

  @override
  Future<void> enableSessionWakelock() async => wakelockEnabled = true;

  @override
  Future<void> disableSessionWakelock() async => wakelockEnabled = false;
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final platformServiceProvider = Provider<PlatformService>((ref) {
  return RealPlatformService();
});
