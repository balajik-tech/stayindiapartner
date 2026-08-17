import 'package:get_it/get_it.dart';
import 'package:stayindia_owner/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:stayindia_owner/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:stayindia_owner/features/profile/domain/repositories/profile_repository.dart';
import 'package:stayindia_owner/features/profile/domain/usecases/profile_usecases.dart';
import 'package:stayindia_owner/features/profile/domain/usecases/hostel_usecases.dart';
import 'package:stayindia_owner/features/profile/domain/usecases/room_usecases.dart';
import 'package:stayindia_owner/features/profile/domain/usecases/food_menu_usecases.dart';
import 'package:stayindia_owner/features/profile/domain/usecases/settings_usecases.dart';
import 'package:stayindia_owner/features/profile/domain/usecases/document_usecases.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/profile_cubit.dart';

import 'data/datasources/hostel_remote_datasource.dart';
import 'data/datasources/room_remote_datasource.dart';
import 'data/datasources/food_menu_remote_datasource.dart';
import 'data/datasources/settings_remote_datasource.dart';
import 'data/datasources/document_remote_datasource.dart';
import 'data/datasources/review_remote_datasource.dart';

import 'data/repositories/hostel_repository_impl.dart';
import 'data/repositories/room_repository_impl.dart';
import 'data/repositories/food_menu_repository_impl.dart';
import 'data/repositories/settings_repository_impl.dart';
import 'data/repositories/document_repository_impl.dart';

import 'domain/repositories/hostel_repository.dart';
import 'domain/repositories/room_repository.dart';
import 'domain/repositories/food_menu_repository.dart';
import 'domain/repositories/settings_repository.dart';
import 'domain/repositories/document_repository.dart';
import 'domain/repositories/review_repository.dart';

import 'presentation/cubit/hostel_cubit.dart';
import 'presentation/cubit/room_cubit.dart';
import 'presentation/cubit/food_menu_cubit.dart';
import 'presentation/cubit/settings_cubit.dart';
import 'package:stayindia_owner/features/profile/data/repositories/review_repository_impl.dart';
import 'package:stayindia_owner/features/profile/data/repositories/subscription_repository_impl.dart';
import 'package:stayindia_owner/features/profile/data/datasources/subscription_remote_datasource.dart';
import 'package:stayindia_owner/features/profile/domain/repositories/subscription_repository.dart';
import 'package:stayindia_owner/features/profile/domain/usecases/subscription_usecases.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/subscription_cubit.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/document_cubit.dart';

void registerProfileFeature(GetIt sl) {
  sl.registerFactory(
    () => ProfileCubit(
      getProfileUseCase: sl(),
      updateProfileUseCase: sl(),
      uploadAvatarUseCase: sl(),
      deleteOwnerAccountUseCase: sl(),
      generateReferralUseCase: sl(),
      getRateUsUrlUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => HostelCubit(
      getHostelsUseCase: sl(),
      createHostelUseCase: sl(),
      updateHostelUseCase: sl(),
      deleteHostelUseCase: sl(),
      uploadHostelImagesUseCase: sl(),
      updateHostelLocationUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => SubscriptionCubit(
      getSubscriptionPlansUseCase: sl(),
      subscribeToPlanUseCase: sl(),
      verifyPaymentUseCase: sl(),
      getPaymentSummaryUseCase: sl(),
      getPaymentReceiptUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => RoomCubit(
      getOccupancyUseCase: sl(),
      getFloorWiseRoomsUseCase: sl(),
      getRoomsUseCase: sl(),
      getFloorsUseCase: sl(),
      getRoomsByFloorUseCase: sl(),
      getFreeBedsUseCase: sl(),
      createRoomUseCase: sl(),
      updateRoomUseCase: sl(),
      deleteRoomUseCase: sl(),
      getBedDetailUseCase: sl(),
      getBedHistoryUseCase: sl(),
      bulkCreateRoomsUseCase: sl(),
      bulkUpsertRoomsUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => FoodMenuCubit(getFoodMenuUseCase: sl(), saveFoodMenuUseCase: sl()),
  );

  sl.registerFactory(
    () => SettingsCubit(
      getHostelSettingsUseCase: sl(),
      updateHostelProfileUseCase: sl(),
      updateHostelAmenitiesUseCase: sl(),
      updateHostelHouseRulesUseCase: sl(),
      updateHostelNotificationsUseCase: sl(),
      updateHostelRoomConfigUseCase: sl(),
      uploadHostelSettingsImagesUseCase: sl(),
      uploadSingleImageUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => DocumentCubit(
      getDocumentsUseCase: sl(),
      uploadDocumentUseCase: sl(),
      deleteDocumentUseCase: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => UploadAvatarUseCase(sl()));
  sl.registerLazySingleton(() => DeleteOwnerAccountUseCase(sl()));
  sl.registerLazySingleton(() => GenerateReferralUseCase(sl()));
  sl.registerLazySingleton(() => GetRateUsUrlUseCase(sl()));

  sl.registerLazySingleton(() => GetHostelsUseCase(sl()));
  sl.registerLazySingleton(() => CreateHostelUseCase(sl()));
  sl.registerLazySingleton(() => UpdateHostelUseCase(sl()));
  sl.registerLazySingleton(() => DeleteHostelUseCase(sl()));
  sl.registerLazySingleton(() => UploadHostelImagesUseCase(sl()));
  sl.registerLazySingleton(() => UpdateHostelLocationUseCase(sl()));
  sl.registerLazySingleton(() => GetSubscriptionPlansUseCase(sl()));
  sl.registerLazySingleton(() => SubscribeToPlanUseCase(sl()));
  sl.registerLazySingleton(() => VerifySubscriptionPaymentUseCase(sl()));
  sl.registerLazySingleton(() => GetPaymentSummaryUseCase(sl()));
  sl.registerLazySingleton(() => GetPaymentReceiptUseCase(sl()));

  sl.registerLazySingleton(() => GetOccupancyUseCase(sl()));
  sl.registerLazySingleton(() => GetFloorWiseRoomsUseCase(sl()));
  sl.registerLazySingleton(() => GetRoomsUseCase(sl()));
  sl.registerLazySingleton(() => GetFloorsUseCase(sl()));
  sl.registerLazySingleton(() => GetRoomsByFloorUseCase(sl()));
  sl.registerLazySingleton(() => GetFreeBedsUseCase(sl()));
  sl.registerLazySingleton(() => CreateRoomUseCase(sl()));
  sl.registerLazySingleton(() => UpdateRoomUseCase(sl()));
  sl.registerLazySingleton(() => DeleteRoomUseCase(sl()));
  sl.registerLazySingleton(() => GetBedDetailUseCase(sl()));
  sl.registerLazySingleton(() => GetBedHistoryUseCase(sl()));
  sl.registerLazySingleton(() => BulkCreateRoomsUseCase(sl()));
  sl.registerLazySingleton(() => BulkUpsertRoomsUseCase(sl()));

  sl.registerLazySingleton(() => GetFoodMenuUseCase(sl()));
  sl.registerLazySingleton(() => SaveFoodMenuUseCase(sl()));

  sl.registerLazySingleton(() => GetHostelSettingsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateHostelProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateHostelAmenitiesUseCase(sl()));
  sl.registerLazySingleton(() => UpdateHostelHouseRulesUseCase(sl()));
  sl.registerLazySingleton(() => UpdateHostelNotificationsUseCase(sl()));
  sl.registerLazySingleton(() => UpdateHostelRoomConfigUseCase(sl()));
  sl.registerLazySingleton(() => UploadHostelSettingsImagesUseCase(sl()));
  sl.registerLazySingleton(() => UploadSingleImageUseCase(sl()));

  sl.registerLazySingleton(() => GetDocumentsUseCase(sl()));
  sl.registerLazySingleton(() => UploadDocumentUseCase(sl()));
  sl.registerLazySingleton(() => DeleteDocumentUseCase(sl()));

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<HostelRepository>(
    () => HostelRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<RoomRepository>(
    () => RoomRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<FoodMenuRepository>(
    () => FoodMenuRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<DocumentRepository>(
    () => DocumentRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ReviewRepository>(
    () => ReviewRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<SubscriptionRepository>(
    () => SubscriptionRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<HostelRemoteDataSource>(
    () => HostelRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<RoomRemoteDataSource>(
    () => RoomRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<FoodMenuRemoteDataSource>(
    () => FoodMenuRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<SettingsRemoteDataSource>(
    () => SettingsRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<DocumentRemoteDataSource>(
    () => DocumentRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<ReviewRemoteDataSource>(
    () => ReviewRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<SubscriptionRemoteDataSource>(
    () => SubscriptionRemoteDataSourceImpl(dio: sl()),
  );
}
