import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/bank_account_entity.dart';
import '../../domain/entities/bank_account_verification_result.dart';
import '../../domain/usecases/add_bank_account.dart';
import '../../domain/usecases/verify_bank_account.dart';

part 'add_bank_account_state.dart';

class AddBankAccountCubit extends Cubit<AddBankAccountState> {
  final AddBankAccount addBankAccount;
  final VerifyBankAccount verifyBankAccount;

  AddBankAccountCubit({
    required this.addBankAccount,
    required this.verifyBankAccount,
  }) : super(const AddBankAccountState());

  Future<void> submit({
    required String propertyId,
    required String accountNumber,
    required String confirmAccountNumber,
    required String ifscCode,
    required String accountHolderName,
    required BankAccountType accountType,
  }) async {
    final branchName = state.verificationResult?.branchName ?? 'Hyderabad';
    final bankName = state.verificationResult?.bankName ?? "SBI";
    emit(state.copyWith(isSubmitting: true, clearSubmitError: true, clearVerifyError: true, clearVerifySuccess: true));

    final result = await addBankAccount(
      AddBankAccountParams(
        propertyId: propertyId,
        accountNumber: accountNumber,
        confirmAccountNumber: confirmAccountNumber,
        ifscCode: ifscCode,
        accountHolderName: accountHolderName,
        accountType: accountType,
        branchName: branchName,
        bankName: bankName,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(isSubmitting: false, submitError: failure.message)),
      (account) => emit(state.copyWith(isSubmitting: false, createdAccount: account)),
    );
  }

  Future<void> verify({
    required String accountNumber,
    required String ifscCode,
    required String clientRefNum,
  }) async {
    emit(state.copyWith(isVerifying: true, clearVerifyError: true, clearVerifySuccess: true));

    final result = await verifyBankAccount(
      VerifyBankAccountParams(
        accountNumber: accountNumber,
        ifscCode: ifscCode,
        clientRefNum: clientRefNum,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(isVerifying: false, verifyError: failure.message)),
      (verificationResult) => emit(state.copyWith(
        isVerifying: false,
        verifySuccess: true,
        verificationResult: verificationResult,
      )),
    );
  }
}
