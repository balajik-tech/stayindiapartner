import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'data/datasources/stock_remote_datasource.dart';
import 'data/repositories/stock_repository_impl.dart';
import 'domain/repositories/stock_repository.dart';
import 'presentation/cubit/stock_cubit.dart';

void registerStockManagementFeature(GetIt sl) {
  sl.registerFactory(() => StockCubit(repository: sl()));

  sl.registerLazySingleton<StockRepository>(
    () => StockRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<StockRemoteDataSource>(
    () => StockRemoteDataSourceImpl(dio: sl<Dio>()),
  );
}
