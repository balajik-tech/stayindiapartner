import 'package:get_it/get_it.dart';
import 'data/datasources/finance_remote_datasource.dart';
import 'data/repositories/finance_repository_impl.dart';
import 'domain/repositories/finance_repository.dart';
import 'domain/usecases/finance_usecases.dart';
import 'domain/usecases/get_revenue_history_usecase.dart';
import 'presentation/cubit/finance_cubit.dart';
import 'presentation/cubit/revenue_history_cubit.dart';

final sl = GetIt.instance;

void initFinanceInjections() {
  sl.registerFactory(
    () => FinanceCubit(
      getFinancialStatsUseCase: sl(),
      getRevenueAnalyticsUseCase: sl(),
    ),
  );
  sl.registerFactory(() => RevenueHistoryCubit(getRevenueHistory: sl()));

  sl.registerLazySingleton(() => GetFinancialStatsUseCase(sl()));
  sl.registerLazySingleton(() => GetRevenueAnalyticsUseCase(sl()));
  sl.registerLazySingleton(() => GetRevenueHistoryUseCase(repository: sl()));

  sl.registerLazySingleton<FinanceRepository>(
    () => FinanceRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<FinanceRemoteDataSource>(
    () => FinanceRemoteDataSourceImpl(dio: sl()),
  );
}
