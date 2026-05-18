import 'package:get_it/get_it.dart';
import 'data/datasources/dashboard_remote_datasource.dart';
import 'data/repositories/dashboard_repository_impl.dart';
import 'domain/repositories/dashboard_repository.dart';
import 'domain/usecases/get_dashboard_data_usecase.dart';
import 'domain/usecases/get_rent_due_details_usecase.dart';
import 'presentation/cubit/dashboard_cubit.dart';
import 'presentation/cubit/rent_due_cubit.dart';

void registerDashboardFeature(GetIt sl) {
  sl.registerFactory(
    () =>
        DashboardCubit(getDashboardDataUseCase: sl(), deleteRoomUseCase: sl()),
  );

  sl.registerLazySingleton(() => GetDashboardDataUseCase(sl()));

  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(remote: sl()),
  );

  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton(() => GetRentDueDetailsUseCase(repository: sl()));
  sl.registerFactory(() => RentDueCubit(getRentDueDetails: sl()));
}
