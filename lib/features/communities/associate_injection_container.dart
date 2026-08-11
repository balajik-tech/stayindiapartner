import 'package:get_it/get_it.dart';

import 'data/datasources/community_static_datasource.dart';
import 'data/repositories/association_repository_impl.dart';
import 'domain/repositories/associate_repository.dart';
import 'domain/usecases/get_executive_committee_usecase.dart';
import 'domain/usecases/get_executive_members_usecase.dart';
import 'domain/usecases/get_it_wing_members_usecase.dart';
import 'domain/usecases/get_community_theme_usecase.dart';
import 'domain/usecases/get_association_details_usecase.dart';
import 'presentation/cubit/associate_home_cubit.dart';

void registerAssociateHomeDataFeature(GetIt sl) {
  // Data source
  sl.registerLazySingleton<AssociateDataSource>(
        () => const AssociateStaticDataSource(),
  );

  // Repository
  sl.registerLazySingleton<AssociateRepository>(
        () => AssociateRepositoryImpl(sl<AssociateDataSource>()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetExecutiveCommitteeUseCase(sl<AssociateRepository>()));
  sl.registerLazySingleton(() => GetExecutiveMembersUseCase(sl<AssociateRepository>()));
  sl.registerLazySingleton(() => GetItWingMembersUseCase(sl<AssociateRepository>()));
  sl.registerLazySingleton(() => GetCommunityThemeUseCase(sl<AssociateRepository>()));
  sl.registerLazySingleton(() => GetAssociationDetailsUseCase(sl<AssociateRepository>()));

  // Cubit — factory, so every navigation to the page gets a fresh instance
  sl.registerFactory(
        () => AssociateHomeDataCubit(
      getExecutiveCommittee: sl<GetExecutiveCommitteeUseCase>(),
      getExecutiveMembers: sl<GetExecutiveMembersUseCase>(),
      getItWingMembers: sl<GetItWingMembersUseCase>(),
      getCommunityTheme: sl<GetCommunityThemeUseCase>(),
      getAssociationDetails: sl<GetAssociationDetailsUseCase>(),
    ),
  );
}
