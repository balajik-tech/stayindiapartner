import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'data/datasource/guest_remote_datasource.dart';
import 'data/repositories/guest_repository_impl.dart';
import 'domain/repositories/guest_repository.dart';
import 'presentation/cubit/guest_cubit.dart';

void registerGuestFeature(GetIt sl) {

  sl.registerFactory(() => GuestCubit(repository: sl()));

  sl.registerLazySingleton<GuestRepository>(
    () => GuestRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<GuestRemoteDataSource>(
    () => GuestRemoteDataSourceImpl(dio: sl<Dio>()),
  );
}
