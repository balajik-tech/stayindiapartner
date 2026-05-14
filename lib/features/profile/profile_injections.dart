import 'package:get_it/get_it.dart';
import 'package:stayindia_owner/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:stayindia_owner/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:stayindia_owner/features/profile/domain/repositories/profile_repository.dart';
import 'package:stayindia_owner/features/profile/domain/usecases/profile_usecases.dart';
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
import 'package:stayindia_owner/features/auth/presentation/cubit/document_cubit.dart';

void registerProfileFeature(GetIt sl) {
  sl.registerFactory(() => ProfileCubit(
        getProfileUseCase: sl(),
        updateProfileUseCase: sl(),
        uploadAvatarUseCase: sl(),
        deleteOwnerAccountUseCase: sl(),
      ));
  
  sl.registerFactory(() => HostelCubit(
        getHostelsUseCase: sl(),
        createHostelUseCase: sl(),
        updateHostelUseCase: sl(),
        deleteHostelUseCase: sl(),
        uploadHostelImagesUseCase: sl(),
        updateHostelLocationUseCase: sl(),
      ));

  sl.registerFactory(() => RoomCubit(
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
      ));

  sl.registerFactory(() => FoodMenuCubit(
        getFoodMenuUseCase: sl(),
        saveFoodMenuUseCase: sl(),
      ));

  sl.registerFactory(() => SettingsCubit(
        getHostelSettingsUseCase: sl(),
        updateHostelProfileUseCase: sl(),
        updateHostelAmenitiesUseCase: sl(),
        updateHostelHouseRulesUseCase: sl(),
        updateHostelNotificationsUseCase: sl(),
        updateHostelRoomConfigUseCase: sl(),
        uploadHostelSettingsImagesUseCase: sl(),
      ));

  sl.registerFactory(() => DocumentCubit(
        getDocumentsUseCase: sl(),
        uploadDocumentUseCase: sl(),
        deleteDocumentUseCase: sl(),
      ));

  // ── Use-cases ──────────────────────────────────────────────────────────────
  sl.registerLazySingleton(() => GetProfileUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProfileUseCase(sl()));
  sl.registerLazySingleton(() => UploadAvatarUseCase(sl()));
  sl.registerLazySingleton(() => DeleteOwnerAccountUseCase(sl()));

  // ── Repository ─────────────────────────────────────────────────────────────
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

  // ── Data sources ────────────────────────────────────────────────────────────
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
}
