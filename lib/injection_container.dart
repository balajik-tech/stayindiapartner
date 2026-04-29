import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:stayindia_owner/core/services/token_storage.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/core/socket/socket_service.dart';
import 'package:stayindia_owner/core/services/notification_service.dart';
import 'package:stayindia_owner/core/utils/logger.dart';
import 'package:stayindia_owner/core/network/error_interceptor.dart';
import 'package:stayindia_owner/core/network/connectivity_interceptor.dart';
import 'package:stayindia_owner/core/location/location_cubit.dart';
import 'package:stayindia_owner/core/location/location_service.dart';

import 'package:stayindia_owner/features/auth/auth_injections.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stayindia_owner/features/bookings/bookings_injections.dart';
import 'package:stayindia_owner/features/dashboard/dashboard_injections.dart';
import 'package:stayindia_owner/features/communities/community_injections.dart';
import 'package:stayindia_owner/features/tenants/tenants_injections.dart';
import 'package:stayindia_owner/features/profile/profile_injections.dart';
import 'package:stayindia_owner/features/staff/staff_injections.dart';
import 'package:stayindia_owner/features/notices/notice_injections.dart';
import 'package:stayindia_owner/features/payments/payment_injections.dart';
import 'package:stayindia_owner/features/maintenance/maintenance_injections.dart';
import 'package:stayindia_owner/features/finance/finance_injections.dart';

final sl = GetIt.instance;

Future<void> init() async {
  
  registerAuthFeature(sl);
  registerDashboardFeature(sl);
  registerBookingsFeature(sl);
  registerCommunityFeature(sl);
  registerTenantsFeature(sl);
  registerProfileFeature(sl);
  registerStaffFeature(sl);
  registerNoticeFeature(sl);
  registerPaymentFeature(sl);
  registerMaintenanceFeature(sl);
  initFinanceInjections();
  
  
  sl.registerFactory(() => LocationCubit(sl()));
  sl.registerLazySingleton(() => LocationService());
  sl.registerLazySingleton(() => TokenStorage(storage: sl<FlutterSecureStorage>()));
  sl.registerLazySingleton(() => NotificationService());
  sl.registerLazySingleton(() => const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      ));

  sl.registerLazySingleton<SocketService>(() {
    String socketBaseUrl = ApiConstants.baseUrl;
    if (socketBaseUrl.contains('/api/v1')) {
      socketBaseUrl = socketBaseUrl.replaceAll('/api/v1', '');
    } else if (socketBaseUrl.contains('/api')) {
      socketBaseUrl = socketBaseUrl.replaceAll('/api', '');
    }
    return SocketService(baseUrl: socketBaseUrl)..connect();
  });

  
  sl.registerLazySingleton(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );
    
    dio.interceptors.addAll([
      ConnectivityInterceptor(),
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await sl<TokenStorage>().getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Accept'] = 'application/json';
          if (['POST', 'PUT', 'PATCH'].contains(options.method)) {
            options.headers['Content-Type'] = 'application/json';
          }
          AppLogger.debug('[REQUEST] ${options.method} ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.debug('[RESPONSE] ${response.requestOptions.method} ${response.requestOptions.uri} -> Status: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            final isAuthPath = e.requestOptions.path.contains('/auth/') || 
                              e.requestOptions.path.contains('/users/');
            if (!isAuthPath) {
              AppLogger.warning('Session expired (401). Logging out...');
              sl<AuthCubit>().logout();
            }
          }
          return handler.next(e);
        },
      ),
      ErrorInterceptor(),
    ]);
    
    return dio;
  });
}
