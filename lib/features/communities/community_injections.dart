import 'package:get_it/get_it.dart';
import 'data/datasources/community_remote_datasource.dart';
import 'data/repositories/community_repository_impl.dart';
import 'domain/repositories/community_repository.dart';
import 'domain/usecases/community_usecases.dart';
import 'presentation/cubit/community_cubit.dart';
import 'presentation/cubit/owner_community_cubit.dart';
import 'presentation/cubit/association_cubit.dart';
import 'presentation/cubit/social_feed_cubit.dart';

void registerCommunityFeature(GetIt sl) {
  sl.registerFactory(
    () => CommunityCubit(
      getCommunityDetailsUseCase: sl(),
      getCommunityMessagesUseCase: sl(),
      sendCommunityMessageUseCase: sl(),
      editCommunityMessageUseCase: sl(),
      deleteCommunityMessageUseCase: sl(),
      sendCommunityImageUseCase: sl(),
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
      getAssociationsPortalUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => AssociationCubit(
      getAssociationsUseCase: sl(),
      searchAssociationsUseCase: sl(),
      joinAssociationUseCase: sl(),
      createAssociationUseCase: sl(),
      profileCubit: sl(),
    ),
  );

  sl.registerFactory(
    () => SocialFeedCubit(
      getSocialFeedUseCase: sl(),
      getOfficialFeedUseCase: sl(),
      createSocialPostUseCase: sl(),
      togglePostLikeUseCase: sl(),
      addPostCommentUseCase: sl(),
      votePollUseCase: sl(),
      deleteSocialPostUseCase: sl(),
      updateSocialPostUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetCommunityDetailsUseCase(sl()));
  sl.registerLazySingleton(() => GetCommunityMessagesUseCase(sl()));
  sl.registerLazySingleton(() => SendCommunityMessageUseCase(sl()));
  sl.registerLazySingleton(() => EditCommunityMessageUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCommunityMessageUseCase(sl()));
  sl.registerLazySingleton(() => SendCommunityImageUseCase(sl()));
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
  sl.registerLazySingleton(() => UpdateOwnerCommunityUseCase(sl()));
  sl.registerLazySingleton(() => GetAssociationsUseCase(sl()));
  sl.registerLazySingleton(() => SearchAssociationsUseCase(sl()));
  sl.registerLazySingleton(() => JoinAssociationUseCase(sl()));
  sl.registerLazySingleton(() => CreateAssociationUseCase(sl()));
  sl.registerLazySingleton(() => GetSocialFeedUseCase(sl()));
  sl.registerLazySingleton(() => GetOfficialFeedUseCase(sl()));
  sl.registerLazySingleton(() => CreateSocialPostUseCase(sl()));
  sl.registerLazySingleton(() => TogglePostLikeUseCase(sl()));
  sl.registerLazySingleton(() => GetPostCommentsUseCase(sl()));
  sl.registerLazySingleton(() => AddPostCommentUseCase(sl()));
  sl.registerLazySingleton(() => VotePollUseCase(sl()));
  sl.registerLazySingleton(() => DeleteSocialPostUseCase(sl()));
  sl.registerLazySingleton(() => UpdateSocialPostUseCase(sl()));

  sl.registerLazySingleton<CommunityRepository>(
    () => CommunityRepositoryImpl(remote: sl()),
  );

  sl.registerLazySingleton<CommunityRemoteDataSource>(
    () => CommunityRemoteDataSourceImpl(dio: sl()),
  );
}
