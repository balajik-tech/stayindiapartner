import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'data/datasources/notice_remote_datasource.dart';
import 'data/repositories/notice_repository_impl.dart';
import 'domain/repositories/notice_repository.dart';
import 'domain/usecases/notice_usecases.dart';
import 'presentation/cubit/notice_cubit.dart';

void registerNoticeFeature(GetIt sl) {
  sl.registerFactory(
    () => NoticeCubit(
      createNoticeUseCase: sl(),
      getNoticesUseCase: sl(),
      getNoticeByIdUseCase: sl(),
      updateNoticeUseCase: sl(),
      postAnnouncementUseCase: sl(),
      getAnnouncementsUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(() => CreateNoticeUseCase(sl()));
  sl.registerLazySingleton(() => GetNoticesUseCase(sl()));
  sl.registerLazySingleton(() => GetNoticeByIdUseCase(sl()));
  sl.registerLazySingleton(() => UpdateNoticeUseCase(sl()));

  sl.registerLazySingleton<NoticeRepository>(
    () => NoticeRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<NoticeRemoteDataSource>(
    () => NoticeRemoteDataSourceImpl(dio: sl<Dio>()),
  );
}
