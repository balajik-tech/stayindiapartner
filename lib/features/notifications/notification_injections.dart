import 'package:get_it/get_it.dart';
import 'data/datasources/notification_remote_datasource.dart';
import 'data/repositories/notification_repository_impl.dart';
import 'domain/repositories/notification_repository.dart';
import 'presentation/cubit/notification_cubit.dart';

void registerNotificationFeature(GetIt sl) {
  
  sl.registerFactory(() => NotificationCubit(repository: sl()));

  
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(remoteDataSource: sl()),
  );

  
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(sl()),
  );
}
