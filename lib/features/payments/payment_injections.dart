import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'data/datasources/payment_remote_datasource.dart';
import 'data/repositories/payment_repository_impl.dart';
import 'domain/repositories/payment_repository.dart';
import 'domain/usecases/payment_usecases.dart';
import 'presentation/cubit/payment_cubit.dart';

void registerPaymentFeature(GetIt sl) {
  
  sl.registerFactory(() => PaymentCubit(
        getPaymentsUseCase: sl(),
        createPaymentUseCase: sl(),
        markPaymentPaidUseCase: sl(),
        sendPaymentReminderUseCase: sl(),
        sendBulkPaymentReminderUseCase: sl(),
        getReminderHistoryUseCase: sl(),
        getBillsUseCase: sl(),
      ));

  
  sl.registerLazySingleton(() => GetPaymentsUseCase(sl()));
  sl.registerLazySingleton(() => CreatePaymentUseCase(sl()));
  sl.registerLazySingleton(() => MarkPaymentPaidUseCase(sl()));
  sl.registerLazySingleton(() => SendPaymentReminderUseCase(sl()));
  sl.registerLazySingleton(() => SendBulkPaymentReminderUseCase(sl()));
  sl.registerLazySingleton(() => GetReminderHistoryUseCase(sl()));
  sl.registerLazySingleton(() => GetBillsUseCase(sl()));

  
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(remoteDataSource: sl()),
  );

  
  sl.registerLazySingleton<PaymentRemoteDataSource>(
    () => PaymentRemoteDataSourceImpl(dio: sl<Dio>()),
  );
}
