import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stayindia_owner/features/auth/data/datasources/otp_attempt_local_datasource.dart';

void main() {
  late OtpAttemptLocalDataSourceImpl dataSource;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    dataSource = OtpAttemptLocalDataSourceImpl();
  });

  test('allows the first OTP plus 5 resends, then locks', () async {
    for (var i = 0; i < OtpAttemptLocalDataSourceImpl.maxRequests; i++) {
      expect(await dataSource.registerRequest(), isNull);
    }

    final lockedUntil = await dataSource.registerRequest();
    expect(lockedUntil, isNotNull);
    expect(lockedUntil!.isAfter(DateTime.now()), isTrue);
  });

  test('lockout persists across instances (app restart)', () async {
    await dataSource.lock();

    final afterRestart = OtpAttemptLocalDataSourceImpl();
    expect(await afterRestart.getLockedUntil(), isNotNull);
    expect(await afterRestart.registerRequest(), isNotNull);
  });

  test('expired lockout is cleared', () async {
    await dataSource.lock(duration: const Duration(milliseconds: 1));
    await Future<void>.delayed(const Duration(milliseconds: 5));

    expect(await dataSource.getLockedUntil(), isNull);
    expect(await dataSource.registerRequest(), isNull);
  });

  test('reset clears the counter', () async {
    for (var i = 0; i < OtpAttemptLocalDataSourceImpl.maxRequests; i++) {
      await dataSource.registerRequest();
    }
    await dataSource.reset();

    expect(await dataSource.registerRequest(), isNull);
  });
}
