import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/session_service.dart';

/// Whether a workout session is currently active. Derived from the session
/// engine; consumed by the bottom nav and page shell.
final activeSessionProvider = Provider<bool>(
  (ref) => ref.watch(sessionEngineProvider) != null,
);
