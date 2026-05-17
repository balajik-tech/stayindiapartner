import 'package:get_it/get_it.dart';
import 'package:stayindia_owner/features/tenants/data/datasources/tenant_remote_datasource.dart';
import 'package:stayindia_owner/features/tenants/data/repositories/tenant_repository_impl.dart';
import 'package:stayindia_owner/features/tenants/domain/repositories/tenant_repository.dart';
import 'package:stayindia_owner/features/tenants/domain/usecases/tenant_usecases.dart';
import 'package:stayindia_owner/features/tenants/domain/usecases/complaint_usecases.dart';
import 'package:stayindia_owner/features/tenants/presentation/cubit/tenant_cubit.dart';
import 'package:stayindia_owner/features/tenants/presentation/cubit/add_tenant_cubit.dart';
import 'package:stayindia_owner/features/tenants/presentation/cubit/complaints_cubit.dart';

void registerTenantsFeature(GetIt sl) {
  sl.registerFactory(() => TenantCubit(getTenantsUseCase: sl()));
  sl.registerFactory(() => TenantDetailCubit(getTenantDetailUseCase: sl()));
  sl.registerFactory(() => AddTenantCubit(
        getFloorsUseCase: sl(),
        getRoomsByFloorUseCase: sl(),
        getFreeBedsUseCase: sl(),
        addTenantUseCase: sl(),
      ));
  sl.registerFactory(() => ComplaintsCubit(
        getComplaintsUseCase: sl(),
        updateStatusUseCase: sl(),
      ));

  sl.registerLazySingleton(() => GetTenantsUseCase(sl()));
  sl.registerLazySingleton(() => GetTenantsForHostelUseCase(sl()));
  sl.registerLazySingleton(() => GetTenantDetailUseCase(sl()));
  sl.registerLazySingleton(() => AddTenantUseCase(sl()));
  sl.registerLazySingleton(() => GetComplaintsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateComplaintStatusUseCase(sl()));

  sl.registerLazySingleton<TenantRepository>(
    () => TenantRepositoryImpl(remote: sl()),
  );

  sl.registerLazySingleton<TenantRemoteDataSource>(
    () => TenantRemoteDataSourceImpl(dio: sl()),
  );
}
