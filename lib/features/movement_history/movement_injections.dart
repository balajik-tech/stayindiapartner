import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:stayindia_owner/features/movement_history/data/datasources/movement_remote_datasource.dart';
import 'package:stayindia_owner/features/movement_history/domain/repositories/movement_repository.dart';
import 'package:stayindia_owner/features/movement_history/presentation/cubit/movement_history_cubit.dart';

void registerMovementFeature(GetIt sl) {
  // Data sources
  sl.registerLazySingleton<MovementRemoteDataSource>(
    () => MovementRemoteDataSource(dio: sl<Dio>()),
  );

  // Repositories
  sl.registerLazySingleton<MovementRepository>(
    () => MovementRepository(remoteDataSource: sl()),
  );

  // Cubits
  sl.registerFactory(() => MovementHistoryCubit(repository: sl()));
}
