import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'data/datasources/staff_remote_datasource.dart';
import 'data/repositories/staff_repository_impl.dart';
import 'domain/repositories/staff_repository.dart';
import 'domain/usecases/staff_usecases.dart';
import 'presentation/cubit/staff_cubit.dart';

void registerStaffFeature(GetIt sl) {
  
  sl.registerFactory(() => StaffCubit(
        getStaffListUseCase: sl(),
        createStaffUseCase: sl(),
        updateStaffUseCase: sl(),
        logStaffActivityUseCase: sl(),
        getStaffByIdUseCase: sl(),
      ));

  
  sl.registerLazySingleton(() => GetStaffListUseCase(sl()));
  sl.registerLazySingleton(() => CreateStaffUseCase(sl()));
  sl.registerLazySingleton(() => UpdateStaffUseCase(sl()));
  sl.registerLazySingleton(() => LogStaffActivityUseCase(sl()));
  sl.registerLazySingleton(() => GetStaffByIdUseCase(sl()));

  
  sl.registerLazySingleton<StaffRepository>(
    () => StaffRepositoryImpl(remoteDataSource: sl()),
  );

  
  sl.registerLazySingleton<StaffRemoteDataSource>(
    () => StaffRemoteDataSourceImpl(dio: sl<Dio>()),
  );
}
