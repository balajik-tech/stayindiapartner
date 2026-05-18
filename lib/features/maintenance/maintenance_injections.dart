import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'data/datasources/maintenance_remote_datasource.dart';
import 'data/repositories/maintenance_repository_impl.dart';
import 'domain/repositories/maintenance_repository.dart';
import 'domain/usecases/maintenance_usecases.dart';
import 'presentation/cubit/maintenance_cubit.dart';

void registerMaintenanceFeature(GetIt sl) {
  sl.registerFactory(
    () => MaintenanceCubit(
      getIssuesUseCase: sl(),
      createIssueUseCase: sl(),
      updateIssueUseCase: sl(),
      getIssueByIdUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetMaintenanceIssuesUseCase(sl()));
  sl.registerLazySingleton(() => CreateMaintenanceIssueUseCase(sl()));
  sl.registerLazySingleton(() => UpdateMaintenanceIssueUseCase(sl()));
  sl.registerLazySingleton(() => GetMaintenanceIssueByIdUseCase(sl()));

  sl.registerLazySingleton<MaintenanceRepository>(
    () => MaintenanceRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<MaintenanceRemoteDataSource>(
    () => MaintenanceRemoteDataSourceImpl(dio: sl<Dio>()),
  );
}
