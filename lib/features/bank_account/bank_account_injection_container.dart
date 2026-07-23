import 'package:get_it/get_it.dart';

import 'data/datasources/bank_account_data_source.dart';
import 'data/repositories/bank_account_repository_impl.dart';
import 'domain/repositories/bank_account_repository.dart';
import 'domain/usecases/add_bank_account.dart';
import 'domain/usecases/get_properties_with_accounts.dart';
import 'domain/usecases/set_primary_account.dart';
import 'presentation/cubit/add_bank_account_cubit.dart';
import 'presentation/cubit/bank_account_cubit.dart';

/// Registers every dependency for the Bank Account feature.
/// Call this from your root `injection_container.dart`:
///
/// ```dart
/// final sl = GetIt.instance;
/// Future<void> init() async {
///   registerAuthFeature(sl);
///   registerBankAccountFeature(sl);
/// }
/// ```
void registerBankAccountFeature(GetIt sl) {
  // Presentation - cubits are recreated per page push, so `registerFactory`.
  sl.registerFactory(
    () => BankAccountCubit(
      getPropertiesWithAccounts: sl(),
      setPrimaryAccount: sl(),
    ),
  );
  sl.registerFactory(
    () => AddBankAccountCubit(
      addBankAccount: sl(),
    ),
  );

  // Domain - use cases
  sl.registerLazySingleton(() => GetPropertiesWithAccounts(sl()));
  sl.registerLazySingleton(() => AddBankAccount(sl()));
  sl.registerLazySingleton(() => SetPrimaryAccount(sl()));

  // Data
  sl.registerLazySingleton<BankAccountRepository>(
    () => BankAccountRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<BankAccountDataSource>(
    () => BankAccountRemoteDataSourceImpl(dio: sl()),
  );
}
