import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'data/datasources/request_service_remote_datasource.dart';
import 'data/repositories/request_service_repository_impl.dart';
import 'domain/repositories/request_service_repository.dart';
import 'domain/usecases/request_service_usecases.dart';
import 'presentation/cubit/request_service_cubit.dart';

void registerRequestServiceFeature(GetIt sl) {
  // Cubits
  sl.registerFactory(
    () => RequestServiceCubit(
      createServiceRequestUseCase: sl(),
      getServiceRequestsUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => CreateServiceRequestUseCase(sl()));
  sl.registerLazySingleton(() => GetServiceRequestsUseCase(sl()));

  // Repository
  sl.registerLazySingleton<RequestServiceRepository>(
    () => RequestServiceRepositoryImpl(remoteDataSource: sl()),
  );

  // Data Source
  sl.registerLazySingleton<RequestServiceRemoteDataSource>(
    () => RequestServiceRemoteDataSourceImpl(dio: sl<Dio>()),
  );
}
