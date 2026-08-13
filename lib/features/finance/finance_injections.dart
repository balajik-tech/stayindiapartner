import 'package:get_it/get_it.dart';
import 'data/datasources/finance_remote_datasource.dart';
import 'data/repositories/finance_repository_impl.dart';
import 'domain/repositories/finance_repository.dart';
import 'domain/usecases/finance_usecases.dart';
import 'domain/usecases/get_revenue_history_usecase.dart';
import 'domain/repositories/payment_repository.dart';
import 'data/repositories/payment_repository_impl.dart';
import 'data/datasources/payment_remote_datasource.dart';
import 'domain/usecases/get_payment_report_usecase.dart';
import 'domain/usecases/record_payment_usecase.dart';
import 'domain/usecases/record_cash_payment_usecase.dart';
import 'presentation/cubit/payment_report_cubit.dart';
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

  sl.registerFactory(
    () => PaymentReportCubit(
      getPaymentReport: sl(),
      recordPayment: sl(),
      getTenants: sl(),
      createCashOrder: sl(),
      recordCashPayment: sl(),
      createUpiOrder: sl(),
      recordUpiPayment: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetFinancialStatsUseCase(sl()));
  sl.registerLazySingleton(() => GetRevenueAnalyticsUseCase(sl()));
  sl.registerLazySingleton(() => GetRevenueHistoryUseCase(repository: sl()));

  sl.registerLazySingleton(() => GetPaymentReportUseCase(repository: sl()));
  sl.registerLazySingleton(() => RecordPaymentUseCase(repository: sl()));
  sl.registerLazySingleton(() => CreateCashOrderUseCase(repository: sl()));
  sl.registerLazySingleton(() => RecordCashPaymentUseCase(repository: sl()));
  sl.registerLazySingleton(() => CreateUpiOrderUseCase(repository: sl()));
  sl.registerLazySingleton(() => RecordUpiPaymentUseCase(repository: sl()));

  sl.registerLazySingleton<FinanceRepository>(
    () => FinanceRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<FinanceRemoteDataSource>(
    () => FinanceRemoteDataSourceImpl(dio: sl()),
  );

  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(dio: sl()),
  );
}
