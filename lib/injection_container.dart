import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:stayindia_owner/core/services/token_storage.dart';
import 'package:stayindia_owner/core/services/cache_service.dart';
import 'package:stayindia_owner/core/services/app_config_service.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/core/socket/socket_service.dart';
import 'package:stayindia_owner/core/services/notification_service.dart';
import 'package:stayindia_owner/core/services/offline_queue_service.dart';
import 'package:stayindia_owner/features/auth/auth_injections.dart';
import 'package:stayindia_owner/features/bookings/bookings_injections.dart';
import 'package:stayindia_owner/features/dashboard/dashboard_injections.dart';
import 'package:stayindia_owner/features/communities/community_injections.dart';
import 'package:stayindia_owner/features/tenants/tenants_injections.dart';
import 'package:stayindia_owner/features/profile/profile_injections.dart';
import 'package:stayindia_owner/features/notices/notice_injections.dart';
import 'package:stayindia_owner/features/payments/payment_injections.dart';
import 'package:stayindia_owner/features/maintenance/maintenance_injections.dart';
import 'package:stayindia_owner/features/staff/staff_injections.dart';
import 'package:stayindia_owner/features/stock_management/stock_management_injections.dart';
import 'package:stayindia_owner/features/finance/finance_injections.dart';
import 'package:stayindia_owner/features/guest/guest_injections.dart';
import 'package:stayindia_owner/features/notifications/notification_injections.dart';
import 'package:stayindia_owner/features/property_setup/property_setup_injections.dart';
import 'package:stayindia_owner/features/offers/offers_injections.dart';
import 'package:stayindia_owner/features/movement_history/movement_injections.dart';
import 'package:stayindia_owner/features/razorpay/razorpay_injections.dart';
import 'package:stayindia_owner/features/request_service/request_service_injections.dart';
import 'package:stayindia_owner/features/electricity_bills/electricity_bills_injections.dart';
import 'package:stayindia_owner/core/theme/theme_cubit.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/guest_session_cubit.dart';
import 'package:stayindia_owner/core/utils/logger.dart';
import 'package:stayindia_owner/core/network/error_interceptor.dart';
import 'package:stayindia_owner/core/network/connectivity_interceptor.dart';
import 'package:stayindia_owner/core/network/retry_interceptor.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stayindia_owner/core/location/location_cubit.dart';
import 'package:stayindia_owner/core/location/location_service.dart';

import 'core/di/feature_di/digilocker_di.dart';
import 'features/bank_account/bank_account_injection_container.dart';
import 'features/communities/associate_injection_container.dart';

final sl = GetIt.instance;

Future<void> init() async {
  registerAuthFeature(sl);
  registerDashboardFeature(sl);
  registerProfileFeature(sl);
  registerBookingsFeature(sl);
  registerCommunityFeature(sl);
  registerTenantsFeature(sl);
  registerNoticeFeature(sl);
  registerPaymentFeature(sl);
  registerMaintenanceFeature(sl);
  registerStaffFeature(sl);
  registerStockManagementFeature(sl);
  initFinanceInjections();
  registerGuestFeature(sl);
  registerNotificationFeature(sl);
  registerPropertySetupFeature(sl);
  registerOffersFeature(sl);
  registerMovementFeature(sl);
  registerRazorpayFeature(sl);
  registerRequestServiceFeature(sl);
  registerElectricityBillsFeature(sl);

  // Register DigiLocker dependencies
  DigiLockerDI.init(sl);
  registerBankAccountFeature(sl);

  registerAssociateHomeDataFeature(sl);

  sl.registerLazySingleton(() => ThemeCubit());
  sl.registerLazySingleton(() => GuestSessionCubit());

  sl.registerFactory(() => LocationCubit(sl()));
  sl.registerLazySingleton(() => LocationService());

  sl.registerLazySingleton(
    () => TokenStorage(storage: sl<FlutterSecureStorage>()),
  );

  sl.registerLazySingleton(() => CacheService(sl()));
  sl.registerLazySingleton(() => AppConfigService());

  sl.registerLazySingleton<SocketService>(() {
    final String socketBaseUrl = Uri.parse(
      ApiConstants.effectiveBaseUrl,
    ).origin;
    return SocketService(baseUrl: socketBaseUrl)..connect();
  });

  sl.registerLazySingleton(() => NotificationService());
  sl.registerLazySingleton(() => OfflineQueueService());

  sl.registerLazySingleton(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: false),
    ),
  );

  sl.registerLazySingleton(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.effectiveBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        sendTimeout: const Duration(seconds: 10),
      ),
    );
    dio.transformer = BackgroundTransformer();

    dio.interceptors.addAll([
      ConnectivityInterceptor(),
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await sl<TokenStorage>().getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['app-type'] = 'OWNER_APP';

          if (options.data is FormData) {
            options.headers.remove('Content-Type');
          } else {
            options.headers['Content-Type'] ??= 'application/json';
          }
          options.headers['Accept'] = 'application/json';

          AppLogger.debug('[REQUEST] ${options.method} ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.debug(
            '[RESPONSE] ${response.requestOptions.method} ${response.requestOptions.uri} -> Status: ${response.statusCode}',
          );
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          final isAuthPath =
              e.requestOptions.path.contains('/auth/') ||
              e.requestOptions.path.contains('/users/');

          final responseData = e.response?.data;
          final isOwnerNotFound =
              responseData?.toString().contains('Owner not found') ?? false;
          final isUserNotFound =
              responseData?.toString().contains('User not found') ?? false;

          final isAuthError =
              e.response?.statusCode == 401 ||
              isOwnerNotFound ||
              isUserNotFound;

          if (isAuthError) {
            if (!isAuthPath || isUserNotFound || isOwnerNotFound) {
              AppLogger.warning(
                'Session expired or User not found on ${e.requestOptions.path}. Logging out...',
              );
              sl<AuthCubit>().logout();
            } else {
              AppLogger.debug(
                '401 on auth path ${e.requestOptions.path}. Letting cubit handle it.',
              );
            }
          } else if (e.response?.statusCode == 403) {
            AppLogger.warning(
              'Access forbidden (403). Possible permission issue.',
            );
          }
          return handler.next(e);
        },
      ),
      ErrorInterceptor(),
      RetryInterceptor(dio: dio),
    ]);

    sl<OfflineQueueService>().startSyncListener(dio);

    return dio;
  });
}

Future<void> resetInjections() async {
  AuthCubit? authCubit;
  ThemeCubit? themeCubit;
  try {
    if (sl.isRegistered<AuthCubit>()) {
      authCubit = sl<AuthCubit>();
    }
  } catch (_) {}
  try {
    if (sl.isRegistered<ThemeCubit>()) {
      themeCubit = sl<ThemeCubit>();
    }
  } catch (_) {}

  await sl.reset();
  await init();

  if (authCubit != null) {
    sl.unregister<AuthCubit>();
    sl.registerSingleton<AuthCubit>(authCubit);
  }
  if (themeCubit != null) {
    sl.unregister<ThemeCubit>();
    sl.registerSingleton<ThemeCubit>(themeCubit);
  }
}
