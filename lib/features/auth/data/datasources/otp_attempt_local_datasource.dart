import 'package:shared_preferences/shared_preferences.dart';

/// Tracks OTP requests on the device so the resend limit and the lockout
/// that follows it survive an app restart.
///
/// The limit is device-wide (not per phone number), so switching numbers
/// doesn't get around it.
abstract class OtpAttemptLocalDataSource {
  /// End of the current lockout, or null when OTP login is allowed.
  Future<DateTime?> getLockedUntil();

  /// Counts one OTP request. Returns the lockout end when the request is
  /// over the limit and must not be sent.
  Future<DateTime?> registerRequest();

  /// Starts a lockout of [duration] (default [lockoutDuration]).
  Future<DateTime> lock({Duration? duration});

  /// Clears all counters, e.g. after a successful verification.
  Future<void> reset();
}

class OtpAttemptLocalDataSourceImpl implements OtpAttemptLocalDataSource {
  /// The first OTP plus 5 resends.
  static const int maxRequests = 6;
  static const Duration window = Duration(minutes: 30);
  static const Duration lockoutDuration = Duration(minutes: 30);

  static const _countKey = 'otp_request_count';
  static const _windowStartKey = 'otp_window_start';
  static const _lockedUntilKey = 'otp_locked_until';

  @override
  Future<DateTime?> getLockedUntil() async {
    final prefs = await SharedPreferences.getInstance();
    final millis = prefs.getInt(_lockedUntilKey);
    if (millis == null) return null;

    final lockedUntil = DateTime.fromMillisecondsSinceEpoch(millis);
    if (DateTime.now().isBefore(lockedUntil)) return lockedUntil;

    await reset();
    return null;
  }

  @override
  Future<DateTime?> registerRequest() async {
    final lockedUntil = await getLockedUntil();
    if (lockedUntil != null) return lockedUntil;

    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final windowStart = prefs.getInt(_windowStartKey);
    var count = prefs.getInt(_countKey) ?? 0;

    if (windowStart == null ||
        now.difference(DateTime.fromMillisecondsSinceEpoch(windowStart)) >
            window) {
      count = 0;
      await prefs.setInt(_windowStartKey, now.millisecondsSinceEpoch);
    }

    if (count >= maxRequests) return lock();

    await prefs.setInt(_countKey, count + 1);
    return null;
  }

  @override
  Future<DateTime> lock({Duration? duration}) async {
    final prefs = await SharedPreferences.getInstance();
    final lockedUntil = DateTime.now().add(duration ?? lockoutDuration);
    await prefs.setInt(_lockedUntilKey, lockedUntil.millisecondsSinceEpoch);
    await prefs.remove(_countKey);
    await prefs.remove(_windowStartKey);
    return lockedUntil;
  }

  @override
  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_countKey);
    await prefs.remove(_windowStartKey);
    await prefs.remove(_lockedUntilKey);
  }
}
