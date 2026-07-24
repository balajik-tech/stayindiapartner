import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/property_entity.dart';
import '../../domain/usecases/delete_bank_account.dart';
import '../../domain/usecases/get_properties_with_accounts.dart';
import '../../domain/usecases/set_primary_account.dart';

part 'bank_account_state.dart';

class BankAccountCubit extends Cubit<BankAccountState> {
  final GetPropertiesWithAccounts getPropertiesWithAccounts;
  final SetPrimaryAccount setPrimaryAccount;
  final DeleteBankAccount deleteBankAccount;

  BankAccountCubit({
    required this.getPropertiesWithAccounts,
    required this.setPrimaryAccount,
    required this.deleteBankAccount,
  }) : super(const BankAccountInitial());

  Future<void> loadProperties() async {
    emit(const BankAccountLoading());
    final result = await getPropertiesWithAccounts(const NoParams());
    result.fold(
      (failure) => emit(BankAccountError(failure.message)),
      (properties) => emit(BankAccountLoaded(properties)),
    );
  }

  Future<void> makePrimary({required String propertyId, required String accountId}) async {
    final current = state;
    if (current is! BankAccountLoaded) return;

    emit(current.copyWith(updatingAccountId: accountId));
    final result = await setPrimaryAccount(
      SetPrimaryAccountParams(propertyId: propertyId, accountId: accountId),
    );

    result.fold(
      (failure) => emit(BankAccountError(failure.message)),
      (_) => loadProperties(),
    );
  }

  Future<void> removeAccount(String accountId) async {
    final current = state;
    if (current is! BankAccountLoaded) return;

    emit(current.copyWith(updatingAccountId: accountId));
    final result = await deleteBankAccount(accountId);

    result.fold(
      (failure) => emit(BankAccountError(failure.message)),
      (_) => loadProperties(),
    );
  }
}
