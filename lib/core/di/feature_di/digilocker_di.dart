import 'package:get_it/get_it.dart';

import '../../../features/digilocker/data/repositories/digilocker_repository_impl.dart';
import '../../../features/digilocker/domain/repositories/digilocker_repository.dart';
import '../../../features/digilocker/domain/usecases/verify_documents.dart';
import '../../../features/digilocker/presentation/cubit/digilocker_cubit.dart';
import '../../../features/auth/domain/repositories/auth_repository.dart';

class DigiLockerDI {
  static void init(GetIt sl) {
    // Repository
    sl.registerLazySingleton<DigiLockerRepository>(
      () => DigiLockerRepositoryImpl(),
    );

    // Use cases
    sl.registerLazySingleton(
      () => VerifyDocuments(sl<DigiLockerRepository>()),
    );

    // Cubit
    sl.registerFactory(
      () => DigiLockerCubit(
        repository: sl<DigiLockerRepository>(),
        authRepository: sl<AuthRepository>(),
      ),
    );
  }
}
