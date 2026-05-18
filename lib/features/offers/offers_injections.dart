import 'package:get_it/get_it.dart';
import 'data/datasources/offer_remote_datasource.dart';
import 'data/repositories/offer_repository_impl.dart';
import 'domain/repositories/offer_repository.dart';
import 'presentation/cubit/offers_cubit.dart';

void registerOffersFeature(GetIt sl) {
  sl.registerLazySingleton<OfferRemoteDataSource>(
    () => OfferRemoteDataSourceImpl(sl()),
  );

  sl.registerLazySingleton<OfferRepository>(
    () => OfferRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerFactory(() => OffersCubit(repository: sl()));
}
