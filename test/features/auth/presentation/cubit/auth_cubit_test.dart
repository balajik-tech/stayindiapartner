import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:stayindia_owner/features/auth/domain/entities/owner_entity.dart';
import 'package:stayindia_owner/features/auth/domain/repositories/auth_repository.dart';
import 'package:stayindia_owner/features/auth/domain/usecases/complete_profile_usecase.dart';
import 'package:stayindia_owner/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:stayindia_owner/features/auth/domain/usecases/get_current_owner_usecase.dart';
import 'package:stayindia_owner/features/auth/domain/usecases/has_active_session_usecase.dart';
import 'package:stayindia_owner/features/auth/domain/usecases/logout_usecase.dart';
import 'package:stayindia_owner/features/auth/domain/usecases/request_otp_usecase.dart';
import 'package:stayindia_owner/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stayindia_owner/core/services/notification_service.dart';

class MockRequestOtpUseCase extends Mock implements RequestOtpUseCase {}
class MockVerifyOtpUseCase extends Mock implements VerifyOtpUseCase {}
class MockGetCurrentOwnerUseCase extends Mock implements GetCurrentOwnerUseCase {}
class MockCompleteProfileUseCase extends Mock implements CompleteProfileUseCase {}
class MockLogoutUseCase extends Mock implements LogoutUseCase {}
class MockHasActiveSessionUseCase extends Mock implements HasActiveSessionUseCase {}
class MockDeleteAccountUseCase extends Mock implements DeleteAccountUseCase {}
class MockAuthRepository extends Mock implements AuthRepository {}
class MockNotificationService extends Mock implements NotificationService {}

void main() {
  late AuthCubit authCubit;
  late MockRequestOtpUseCase mockRequestOtp;
  late MockVerifyOtpUseCase mockVerifyOtp;
  late MockGetCurrentOwnerUseCase mockGetCurrentOwner;
  late MockCompleteProfileUseCase mockCompleteProfile;
  late MockLogoutUseCase mockLogout;
  late MockHasActiveSessionUseCase mockHasActiveSession;
  late MockDeleteAccountUseCase mockDeleteAccount;
  late MockAuthRepository mockAuthRepository;
  late MockNotificationService mockNotificationService;

  setUp(() {
    mockRequestOtp = MockRequestOtpUseCase();
    mockVerifyOtp = MockVerifyOtpUseCase();
    mockGetCurrentOwner = MockGetCurrentOwnerUseCase();
    mockCompleteProfile = MockCompleteProfileUseCase();
    mockLogout = MockLogoutUseCase();
    mockHasActiveSession = MockHasActiveSessionUseCase();
    mockDeleteAccount = MockDeleteAccountUseCase();
    mockAuthRepository = MockAuthRepository();
    mockNotificationService = MockNotificationService();

    authCubit = AuthCubit(
      requestOtpUseCase: mockRequestOtp,
      verifyOtpUseCase: mockVerifyOtp,
      getCurrentOwnerUseCase: mockGetCurrentOwner,
      completeProfileUseCase: mockCompleteProfile,
      logoutUseCase: mockLogout,
      hasActiveSessionUseCase: mockHasActiveSession,
      deleteAccountUseCase: mockDeleteAccount,
      repository: mockAuthRepository,
      notificationService: mockNotificationService,
    );
  });

  tearDown(() {
    authCubit.close();
  });

  test('initial state should be AuthInitial', () {
    expect(authCubit.state, equals(AuthInitial()));
  });

  group('restoreSession', () {
    const tOwner = OwnerEntity(
      id: '1',
      name: 'Test Owner',
      phone: '1234567890',
      isProfileComplete: true,
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthUnauthenticated] when no active session',
      build: () {
        when(() => mockHasActiveSession()).thenAnswer((_) async => false);
        return authCubit;
      },
      act: (cubit) => cubit.restoreSession(),
      expect: () => [AuthUnauthenticated()],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthSessionRestoring, AuthAuthenticated] when session exists',
      build: () {
        when(() => mockHasActiveSession()).thenAnswer((_) async => true);
        when(() => mockGetCurrentOwner()).thenAnswer((_) async => tOwner);
        when(() => mockNotificationService.getToken()).thenAnswer((_) async => 'fake_token');
        return authCubit;
      },
      act: (cubit) => cubit.restoreSession(),
      expect: () => [AuthSessionRestoring(), AuthAuthenticated(owner: tOwner)],
    );
  });

  group('sendOtp', () {
    const tPhone = '1234567890';
    const tOtp = '123456';

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthOtpSent] when sendOtp is successful',
      build: () {
        when(() => mockRequestOtp(any())).thenAnswer((_) async => tOtp);
        return authCubit;
      },
      act: (cubit) => cubit.sendOtp(tPhone),
      expect: () => [
        AuthLoading(),
        AuthOtpSent(phone: tPhone, devOtp: tOtp),
      ],
    );

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthError] when sendOtp fails',
      build: () {
        when(() => mockRequestOtp(any())).thenThrow(Exception('Failed to send OTP'));
        return authCubit;
      },
      act: (cubit) => cubit.sendOtp(tPhone),
      expect: () => [
        AuthLoading(),
        isA<AuthError>(),
      ],
    );
  });
}
