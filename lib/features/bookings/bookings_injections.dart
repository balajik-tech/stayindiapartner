import 'package:get_it/get_it.dart';
import 'data/datasources/bookings_remote_datasource.dart';
import 'data/repositories/bookings_repository_impl.dart';
import 'domain/bookings_repository.dart';
import 'domain/usecases/get_bookings_usecase.dart';
import 'domain/usecases/scan_booking_usecase.dart';
import 'domain/usecases/finalize_checkin_usecase.dart';
import 'domain/usecases/checkout_booking_usecase.dart';
import 'domain/usecases/cancel_booking_usecase.dart';
import 'cubit/bookings_cubit.dart';

void registerBookingsFeature(GetIt sl) {
  // Cubit
  sl.registerFactory(() => BookingsCubit(
        getBookingsUseCase: sl(),
        scanBookingUseCase: sl(),
        finalizeCheckinUseCase: sl(),
        checkoutBookingUseCase: sl(),
        cancelBookingUseCase: sl(),
        getOccupancyUseCase: sl(),
      ));

  // Use Cases
  sl.registerLazySingleton(() => GetBookingsUseCase(repository: sl()));
  sl.registerLazySingleton(() => ScanBookingUseCase(repository: sl()));
  sl.registerLazySingleton(() => FinalizeCheckinUseCase(repository: sl()));
  sl.registerLazySingleton(() => CheckoutBookingUseCase(repository: sl()));
  sl.registerLazySingleton(() => CancelBookingUseCase(repository: sl()));

  // Repository
  sl.registerLazySingleton<BookingsRepository>(
    () => BookingsRepositoryImpl(remote: sl()),
  );

  // Data Source
  sl.registerLazySingleton<BookingsRemoteDataSource>(
    () => BookingsRemoteDataSourceImpl(dio: sl()),
  );
}
