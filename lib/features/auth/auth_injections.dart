import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import 'package:stayindia_owner/core/services/token_storage.dart';
import 'package:stayindia_owner/core/services/notification_service.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'domain/repositories/auth_repository.dart';
import 'domain/usecases/complete_profile_usecase.dart';
import 'domain/usecases/get_current_owner_usecase.dart';
import 'domain/usecases/logout_usecase.dart';
import 'domain/usecases/request_otp_usecase.dart';
import 'domain/usecases/request_otp_via_sms_usecase.dart';
import 'domain/usecases/verify_otp_usecase.dart';
import 'domain/usecases/has_active_session_usecase.dart';
import 'domain/usecases/delete_account_usecase.dart';
import 'presentation/cubit/auth_cubit.dart';

void registerAuthFeature(GetIt sl) {
  sl.registerLazySingleton<AuthCubit>(
    () => AuthCubit(
      requestOtpUseCase: sl(),
      requestOtpViaSmsUseCase: sl(),
      verifyOtpUseCase: sl(),
      getCurrentOwnerUseCase: sl(),
      completeProfileUseCase: sl(),
      logoutUseCase: sl(),
      hasActiveSessionUseCase: sl(),
      deleteAccountUseCase: sl(),
      repository: sl(),
      notificationService: sl(),
      cacheService: sl(),
    ),
  );

  sl.registerLazySingleton(() => RequestOtpUseCase(sl()));
  sl.registerLazySingleton(() => RequestOtpViaSmsUseCase(sl()));
  sl.registerLazySingleton(() => VerifyOtpUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentOwnerUseCase(sl()));
  sl.registerLazySingleton(() => CompleteProfileUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => HasActiveSessionUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAccountUseCase(sl()));

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remote: sl(), tokenStorage: sl()),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      dio: sl<Dio>(),
      tokenStorage: sl<TokenStorage>(),
      notificationService: sl<NotificationService>(),
    ),
  );
}
