import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/bank_account_entity.dart';
import '../../domain/usecases/add_bank_account.dart';

part 'add_bank_account_state.dart';

class AddBankAccountCubit extends Cubit<AddBankAccountState> {
  final AddBankAccount addBankAccount;

  AddBankAccountCubit({
    required this.addBankAccount,
  }) : super(const AddBankAccountState());

  Future<void> submit({
    required String propertyId,
    required String accountNumber,
    required String confirmAccountNumber,
    required String ifscCode,
    required String accountHolderName,
    required BankAccountType accountType,
  }) async {
    emit(state.copyWith(isSubmitting: true, clearSubmitError: true));

    final result = await addBankAccount(
      AddBankAccountParams(
        propertyId: propertyId,
        accountNumber: accountNumber,
        confirmAccountNumber: confirmAccountNumber,
        ifscCode: ifscCode,
        accountHolderName: accountHolderName,
        accountType: accountType,
        branchName: "SBH Hyderabad",
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(isSubmitting: false, submitError: failure.message)),
      (account) => emit(state.copyWith(isSubmitting: false, createdAccount: account)),
    );
  }
}
