import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:stayindia_owner/core/services/token_storage.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/core/socket/socket_service.dart';
import 'package:stayindia_owner/core/services/notification_service.dart';
import 'package:stayindia_owner/domain/repositories/hostel_repository.dart';
import 'package:stayindia_owner/domain/repositories/room_repository.dart';
import 'package:stayindia_owner/domain/repositories/food_menu_repository.dart';
import 'package:stayindia_owner/domain/repositories/settings_repository.dart';
import 'package:stayindia_owner/domain/repositories/complaints_repository.dart';
import 'package:stayindia_owner/domain/repositories/notice_repository.dart';
import 'package:stayindia_owner/domain/repositories/payment_repository.dart';
import 'package:stayindia_owner/domain/repositories/maintenance_repository.dart';
import 'package:stayindia_owner/domain/repositories/staff_repository.dart';
import 'package:stayindia_owner/domain/repositories/document_repository.dart';
import 'package:stayindia_owner/features/auth/auth_injections.dart';
import 'package:stayindia_owner/features/bookings/bookings_injections.dart';
import 'package:stayindia_owner/features/dashboard/dashboard_injections.dart';
import 'package:stayindia_owner/features/communities/community_injections.dart';
import 'package:stayindia_owner/features/tenants/tenants_injections.dart';

import 'package:stayindia_owner/data/data_sources/hostel_remote_data_source.dart';
import 'package:stayindia_owner/data/data_sources/room_remote_data_source.dart';
import 'package:stayindia_owner/data/data_sources/food_menu_remote_data_source.dart';
import 'package:stayindia_owner/data/data_sources/settings_remote_data_source.dart';
import 'package:stayindia_owner/data/data_sources/complaints_remote_data_source.dart';
import 'package:stayindia_owner/data/data_sources/notice_remote_data_source.dart';
import 'package:stayindia_owner/data/data_sources/payment_remote_data_source.dart';
import 'package:stayindia_owner/data/data_sources/maintenance_remote_data_source.dart';
import 'package:stayindia_owner/data/data_sources/staff_remote_data_source.dart';
import 'package:stayindia_owner/data/data_sources/document_remote_data_source.dart';
import 'package:stayindia_owner/data/data_sources/user_remote_data_source.dart';

import 'package:stayindia_owner/data/repositories/hostel_repository_impl.dart';
import 'package:stayindia_owner/data/repositories/room_repository_impl.dart';
import 'package:stayindia_owner/data/repositories/food_menu_repository_impl.dart';
import 'package:stayindia_owner/data/repositories/settings_repository_impl.dart';
import 'package:stayindia_owner/data/repositories/complaints_repository_impl.dart';
import 'package:stayindia_owner/data/repositories/notice_repository_impl.dart';
import 'package:stayindia_owner/data/repositories/payment_repository_impl.dart';
import 'package:stayindia_owner/data/repositories/maintenance_repository_impl.dart';
import 'package:stayindia_owner/data/repositories/staff_repository_impl.dart';
import 'package:stayindia_owner/data/repositories/document_repository_impl.dart';
import 'package:stayindia_owner/core/utils/logger.dart';
import 'package:stayindia_owner/core/network/error_interceptor.dart';
import 'package:stayindia_owner/core/network/connectivity_interceptor.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stayindia_owner/presentation/profile/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/presentation/profile/cubit/room_cubit.dart';
import 'package:stayindia_owner/presentation/profile/cubit/food_menu_cubit.dart';
import 'package:stayindia_owner/presentation/profile/cubit/settings_cubit.dart';
import 'package:stayindia_owner/presentation/notices/cubit/notice_cubit.dart';
import 'package:stayindia_owner/presentation/payments/cubit/payment_cubit.dart';
import 'package:stayindia_owner/presentation/maintenance/cubit/maintenance_cubit.dart';
import 'package:stayindia_owner/presentation/staff/cubit/staff_cubit.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/document_cubit.dart';
import 'package:stayindia_owner/core/location/location_cubit.dart';
import 'package:stayindia_owner/core/location/location_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  registerAuthFeature(sl);
  registerDashboardFeature(sl);
  registerBookingsFeature(sl);
  registerCommunityFeature(sl);
  registerTenantsFeature(sl);
  
  sl.registerFactory(() => HostelCubit(hostelRepository: sl()));
  sl.registerFactory(() => RoomCubit(roomRepository: sl()));
  sl.registerFactory(() => FoodMenuCubit(foodMenuRepository: sl()));
  sl.registerFactory(() => SettingsCubit(settingsRepository: sl()));
  sl.registerFactory(() => NoticeCubit(noticeRepository: sl()));
  sl.registerFactory(() => PaymentCubit(paymentRepository: sl()));
  sl.registerFactory(() => MaintenanceCubit(maintenanceRepository: sl()));
  sl.registerFactory(() => StaffCubit(staffRepository: sl()));
  sl.registerFactory(() => DocumentCubit(documentRepository: sl()));
  sl.registerFactory(() => LocationCubit(sl()));

  sl.registerLazySingleton(() => LocationService());

  sl.registerLazySingleton<HostelRepository>(
    () => HostelRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<RoomRepository>(
    () => RoomRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<FoodMenuRepository>(
    () => FoodMenuRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ComplaintsRepository>(
    () => ComplaintsRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<NoticeRepository>(
    () => NoticeRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<MaintenanceRepository>(
    () => MaintenanceRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<StaffRepository>(
    () => StaffRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<DocumentRepository>(
    () => DocumentRepositoryImpl(remoteDataSource: sl()),
  );
  // Removed legacy DashboardRepository sl registration

  sl.registerLazySingleton<HostelRemoteDataSource>(
    () => HostelRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<RoomRemoteDataSource>(
    () => RoomRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<FoodMenuRemoteDataSource>(
    () => FoodMenuRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<SettingsRemoteDataSource>(
    () => SettingsRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<ComplaintsRemoteDataSource>(
    () => ComplaintsRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<NoticeRemoteDataSource>(
    () => NoticeRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<MaintenanceRemoteDataSource>(
    () => MaintenanceRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<StaffRemoteDataSource>(
    () => StaffRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<DocumentRemoteDataSource>(
    () => DocumentRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSourceImpl(dio: sl()),
  );
  // Removed legacy DashboardRemoteDataSource sl registration

  sl.registerLazySingleton(() => TokenStorage(
        storage: sl<FlutterSecureStorage>(),
      ));

  sl.registerLazySingleton<SocketService>(() {
    final socketBaseUrl = ApiConstants.baseUrl.endsWith('/api') 
        ? ApiConstants.baseUrl.substring(0, ApiConstants.baseUrl.length - 4) 
        : ApiConstants.baseUrl;
    return SocketService(baseUrl: socketBaseUrl)..connect();
  });

  sl.registerLazySingleton(() => NotificationService());

  sl.registerLazySingleton(() => const FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
        ),
      ));

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
          AppLogger.debug('[RESPONSE] ${response.requestOptions.method} ${response.requestOptions.uri} -> Status: ${response.statusCode}');
          return handler.next(response);
        },
        onError: (DioException e, handler) async {
          final isAuthPath = e.requestOptions.path.contains('/auth/') || 
                            e.requestOptions.path.contains('/users/');
          
          if (e.response?.statusCode == 401) {
            // Only trigger global logout for non-auth requests.
            // Auth requests (like /auth/me) should be handled by the AuthCubit.
            if (!isAuthPath) {
              AppLogger.warning('Session expired (401) on ${e.requestOptions.path}. Logging out...');
              sl<AuthCubit>().logout();
            } else {
              AppLogger.debug('401 on auth path ${e.requestOptions.path}. Letting cubit handle it.');
            }
          } else if (e.response?.statusCode == 403) {
            AppLogger.warning('Access forbidden (403). Possible permission issue.');
          }
          return handler.next(e);
        },
      ),
      ErrorInterceptor(),
    ]);
    
    return dio;
  });
}
