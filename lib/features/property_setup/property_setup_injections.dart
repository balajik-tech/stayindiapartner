import 'package:get_it/get_it.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stayindia_owner/features/profile/data/datasources/hostel_remote_datasource.dart';
import 'package:stayindia_owner/features/profile/data/datasources/room_remote_datasource.dart';
import 'data/repositories/property_setup_repository_impl.dart';
import 'domain/repositories/property_setup_repository.dart';
import 'domain/usecases/setup_property_usecase.dart';
import 'presentation/cubit/property_setup_cubit.dart';

void registerPropertySetupFeature(GetIt sl) {
  
  sl.registerFactory(() => PropertySetupCubit(sl()));

  
  sl.registerLazySingleton(() => SetupPropertyUseCase(sl()));

  
  sl.registerLazySingleton<PropertySetupRepository>(
    () => PropertySetupRepositoryImpl(
      hostelRemoteDataSource: sl<HostelRemoteDataSource>(),
      roomRemoteDataSource: sl<RoomRemoteDataSource>(),
      ownerId: sl<AuthCubit>().currentOwner?.id ?? '',
    ),
  );
}
