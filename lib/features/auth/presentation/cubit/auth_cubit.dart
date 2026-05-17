import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:dio/dio.dart';
import 'package:stayindia_owner/core/utils/image_utils.dart';

import 'package:stayindia_owner/features/auth/domain/entities/owner_entity.dart';
import 'package:stayindia_owner/features/auth/domain/usecases/complete_profile_usecase.dart';
import 'package:stayindia_owner/features/auth/domain/usecases/get_current_owner_usecase.dart';
import 'package:stayindia_owner/features/auth/domain/usecases/logout_usecase.dart';
import 'package:stayindia_owner/features/auth/domain/usecases/request_otp_usecase.dart';
import 'package:stayindia_owner/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:stayindia_owner/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:stayindia_owner/features/auth/domain/usecases/has_active_session_usecase.dart';
import 'package:stayindia_owner/core/utils/error_helper.dart';
import 'package:stayindia_owner/core/utils/logger.dart';
import 'package:stayindia_owner/core/services/cache_service.dart';
import 'package:stayindia_owner/features/auth/domain/repositories/auth_repository.dart';
import 'package:stayindia_owner/core/services/notification_service.dart';
import 'package:stayindia_owner/core/services/session_reset_coordinator.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final RequestOtpUseCase _requestOtp;
  final VerifyOtpUseCase _verifyOtp;
  final GetCurrentOwnerUseCase _getCurrentOwner;
  final CompleteProfileUseCase _completeProfile;
  final LogoutUseCase _logout;
  final HasActiveSessionUseCase _hasActiveSession;
  final DeleteAccountUseCase _deleteAccount;

  final AuthRepository _repository;
  final NotificationService _notificationService;
  final CacheService _cacheService;

  AuthCubit({
    required RequestOtpUseCase requestOtpUseCase,
    required VerifyOtpUseCase verifyOtpUseCase,
    required GetCurrentOwnerUseCase getCurrentOwnerUseCase,
    required CompleteProfileUseCase completeProfileUseCase,
    required LogoutUseCase logoutUseCase,
    required HasActiveSessionUseCase hasActiveSessionUseCase,
    required DeleteAccountUseCase deleteAccountUseCase,
    required AuthRepository repository,
    required NotificationService notificationService,
    required CacheService cacheService,
  }) : _requestOtp = requestOtpUseCase,
       _verifyOtp = verifyOtpUseCase,
       _getCurrentOwner = getCurrentOwnerUseCase,
       _completeProfile = completeProfileUseCase,
       _logout = logoutUseCase,
       _hasActiveSession = hasActiveSessionUseCase,
       _deleteAccount = deleteAccountUseCase,
       _repository = repository,
       _notificationService = notificationService,
       _cacheService = cacheService,
       super(AuthInitial()) {
    AppLogger.debug('AuthCubit initialized with ${_cacheService.runtimeType}');
  }

  Future<void> _syncDeviceToken() async {
    try {
      final token = await _notificationService.getToken();
      if (token != null) {
        await _repository.updateDeviceToken(
          pushToken: token,
          platform: Platform.isIOS ? 'ios' : 'android',
        );
        AppLogger.info('Device token synced successfully');
      }
    } catch (e) {
      AppLogger.error('Failed to sync device token: $e');
    }
  }

  Future<void> restoreSession() async {
    final hasSession = await _hasActiveSession();
    if (!hasSession) {
      emit(AuthUnauthenticated());
      return;
    }

    emit(AuthSessionRestoring());
    try {
      final owner = await _getCurrentOwner();
      emit(AuthAuthenticated(owner: owner));
      _syncDeviceToken();
      AppLogger.info('Session restored for owner: ${owner.id}');
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      final responseStr = e.response?.data?.toString() ?? '';
      final isUserNotFound = responseStr.contains('User not found') || responseStr.contains('Owner not found');
      if (code == 401 || code == 403 || code == 404 || isUserNotFound) {
        await _logout();
        emit(AuthUnauthenticated());
      } else {
        emit(
          AuthSessionRestoreError(
            message: 'Connection error. Please check your network.',
          ),
        );
      }
    } catch (e) {
      emit(
        AuthSessionRestoreError(
          message: 'Could not restore your session. Please try again.',
        ),
      );
    }
  }

  Future<void> sendOtp(String phone) async {
    emit(AuthLoading());
    try {
      final devOtp = await _requestOtp(phone);
      emit(AuthOtpSent(phone: phone, devOtp: devOtp));
      AppLogger.info('OTP sent to $phone');
    } catch (e) {
      AppLogger.error('sendOtp failed', e);
      emit(AuthError(message: ErrorHelper.toFriendlyMessage(e)));
    }
  }

  Future<void> resendOtp(String phone) async {
    emit(AuthLoading());
    try {
      final devOtp = await _requestOtp(phone);
      emit(AuthOtpSent(phone: phone, devOtp: devOtp, isResend: true));
    } catch (e) {
      AppLogger.error('resendOtp failed', e);
      emit(AuthError(message: ErrorHelper.toFriendlyMessage(e)));
    }
  }

  Future<void> verifyOtp(String phone, String otp) async {
    emit(AuthLoading());
    try {
      final result = await _verifyOtp(phone, otp);
      AppLogger.info(
        'AuthCubit: OTP verified for ${result.owner.id}. isNewUser: ${result.isNewUser}, isProfileComplete: ${result.owner.isProfileComplete}',
      );
      emit(AuthAuthenticated(owner: result.owner, isNewUser: result.isNewUser));
      _syncDeviceToken();
      AppLogger.info(
        'OTP verified. Owner: ${result.owner.id}, isNewUser: ${result.isNewUser}',
      );
    } catch (e) {
      AppLogger.error('verifyOtp failed', e);
      emit(AuthError(message: ErrorHelper.toFriendlyMessage(e)));
    }
  }

  Future<void> completeProfile(ProfileParams params) async {
    emit(AuthLoading());
    try {
      ProfileParams finalParams = params;
      if (params.avatarPath != null) {
        final imageFile = File(params.avatarPath!);
        if (!imageFile.existsSync()) {
          AppLogger.warning('Avatar file no longer exists at ${params.avatarPath}. Submitting without image.');
          finalParams = ProfileParams(
            firstName: params.firstName,
            lastName: params.lastName,
            email: params.email,
            phone: params.phone,
            address: params.address,
            avatarPath: null,
          );
        } else {
          final compressed = await ImageUtils.compressImage(imageFile);
          if (compressed != null) {
            finalParams = ProfileParams(
              firstName: params.firstName,
              lastName: params.lastName,
              email: params.email,
              phone: params.phone,
              address: params.address,
              avatarPath: compressed.path,
            );
          }
        }
      }
      final owner = await _completeProfile(finalParams);
      emit(AuthProfileCompleted(owner: owner));
      AppLogger.success('Profile completed for owner: ${owner.id}');
    } catch (e) {
      AppLogger.error('completeProfile failed', e);
      emit(AuthError(message: ErrorHelper.toFriendlyMessage(e)));
    }
  }

  Future<void> logout() async {
    try {
      await _logout();
    } catch (e) {
      AppLogger.error('Logout error: $e');
    }
    try {
      await _cacheService.flushAllCache();
    } catch (e) {
      AppLogger.error('Cache flush error: $e');
    }
    await SessionResetCoordinator.resetSession();
    emit(AuthUnauthenticated());
    SessionResetCoordinator.postResetCleanup();
    AppLogger.info('Owner logged out.');
  }

  Future<void> deleteAccount() async {
    emit(AuthLoading());
    try {
      await _deleteAccount();
    } catch (e) {
      AppLogger.error('deleteAccount failed: $e');
    }
    await SessionResetCoordinator.resetSession();
    emit(AuthUnauthenticated());
    SessionResetCoordinator.postResetCleanup();
    AppLogger.info('Owner account deleted.');
  }

  Future<void> refreshProfile() async {
    try {
      final owner = await _getCurrentOwner();
      emit(AuthAuthenticated(owner: owner));
      AppLogger.info('Profile refreshed for owner: ${owner.id}');
    } catch (e) {
      AppLogger.error('refreshProfile failed', e);
    }
  }

  Future<void> acceptPolicy() async {
    try {
      final owner = await _repository.acceptPolicy();
      emit(AuthAuthenticated(owner: owner));
      AppLogger.success('Policy accepted successfully');
    } catch (e) {
      AppLogger.error('acceptPolicy failed', e);
      emit(AuthError(message: ErrorHelper.toFriendlyMessage(e)));
    }
  }

  Future<void> staffLogin(String phone, String password) async {
    emit(AuthLoading());
    try {
      final owner = await _repository.staffLogin(phone, password);
      emit(AuthAuthenticated(owner: owner, isNewUser: false));
      _syncDeviceToken();
      AppLogger.info('Staff logged in successfully. Owner/Staff: ${owner.id}');
    } catch (e) {
      AppLogger.error('staffLogin failed', e);
      emit(AuthError(message: ErrorHelper.toFriendlyMessage(e)));
    }
  }

  OwnerEntity? get currentOwner {
    final s = state;
    return s is AuthAuthenticated ? s.owner : null;
  }
}
