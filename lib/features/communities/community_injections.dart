import 'package:get_it/get_it.dart';
import 'data/datasources/community_remote_datasource.dart';
import 'data/repositories/community_repository_impl.dart';
import 'domain/repositories/community_repository.dart';
import 'domain/usecases/community_usecases.dart';
import 'presentation/cubit/community_cubit.dart';
import 'presentation/cubit/owner_community_cubit.dart';

void registerCommunityFeature(GetIt sl) {
  
  sl.registerFactory(
    () => CommunityCubit(
      getCommunityDetailsUseCase: sl(),
      getCommunityMessagesUseCase: sl(),
      sendCommunityMessageUseCase: sl(),
      getAnnouncementsUseCase: sl(),
      postAnnouncementUseCase: sl(),
      getOwnerDiscussionsUseCase: sl(),
      createOwnerDiscussionUseCase: sl(),
      socketService: sl(),
    ),
  );

  sl.registerFactory(
    () => OwnerCommunityCubit(
      getJoinedOwnerCommunitiesUseCase: sl(),
      getAvailableOwnerCommunitiesUseCase: sl(),
      joinOwnerCommunityUseCase: sl(),
      createOwnerCommunityUseCase: sl(),
      getPendingJoinRequestsUseCase: sl(),
      handleJoinRequestUseCase: sl(),
    ),
  );

  
  sl.registerLazySingleton(() => GetCommunityDetailsUseCase(sl()));
  sl.registerLazySingleton(() => GetCommunityMessagesUseCase(sl()));
  sl.registerLazySingleton(() => SendCommunityMessageUseCase(sl()));
  sl.registerLazySingleton(() => GetAnnouncementsUseCase(sl()));
  sl.registerLazySingleton(() => PostAnnouncementUseCase(sl()));
  sl.registerLazySingleton(() => GetOwnerDiscussionsUseCase(sl()));
  sl.registerLazySingleton(() => CreateOwnerDiscussionUseCase(sl()));
  sl.registerLazySingleton(() => GetJoinedOwnerCommunitiesUseCase(sl()));
  sl.registerLazySingleton(() => GetAvailableOwnerCommunitiesUseCase(sl()));
  sl.registerLazySingleton(() => JoinOwnerCommunityUseCase(sl()));
  sl.registerLazySingleton(() => CreateOwnerCommunityUseCase(sl()));
  sl.registerLazySingleton(() => GetPendingJoinRequestsUseCase(sl()));
  sl.registerLazySingleton(() => HandleJoinRequestUseCase(sl()));
  sl.registerLazySingleton(() => GetCommunityInfoUseCase(sl()));

  
  sl.registerLazySingleton<CommunityRepository>(
    () => CommunityRepositoryImpl(remote: sl()),
  );

  
  sl.registerLazySingleton<CommunityRemoteDataSource>(
    () => CommunityRemoteDataSourceImpl(dio: sl()),
  );
}
