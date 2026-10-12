import 'package:get_it/get_it.dart';
import 'data/datasources/electricity_remote_datasource.dart';
import 'presentation/cubit/electricity_bill_cubit.dart';

void registerElectricityBillsFeature(GetIt sl) {
  sl.registerLazySingleton<ElectricityRemoteDataSource>(
    () => ElectricityRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerFactory(
    () => ElectricityBillCubit(
      getDashboardDataUseCase: sl(),
      remoteDataSource: sl(),
    ),
  );
}
