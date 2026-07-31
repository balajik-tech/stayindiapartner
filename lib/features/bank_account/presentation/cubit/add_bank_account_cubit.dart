import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/bank_account_entity.dart';
import '../../domain/entities/bank_account_verification_result.dart';
import '../../domain/entities/bank_branch_details.dart';
import '../../domain/entities/pan_verification_result.dart';
import '../../domain/usecases/add_bank_account.dart';
import '../../domain/usecases/lookup_ifsc.dart';
import '../../domain/usecases/verify_bank_account.dart';
import '../../domain/usecases/verify_pan.dart';

part 'add_bank_account_state.dart';

class AddBankAccountCubit extends Cubit<AddBankAccountState> {
  final AddBankAccount addBankAccount;
  final VerifyBankAccount verifyBankAccount;
  final LookupIfsc lookupIfsc;
  final VerifyPan verifyPanUseCase;

  AddBankAccountCubit({
    required this.addBankAccount,
    required this.verifyBankAccount,
    required this.lookupIfsc,
    required this.verifyPanUseCase,
  }) : super(const AddBankAccountState());

  Future<void> submit({
    required String propertyId,
    required String accountNumber,
    required String confirmAccountNumber,
    required String ifscCode,
    required String accountHolderName,
    required BankAccountType accountType,
    required String panNumber,
  }) async {
    final branchName = state.verificationResult?.branchName ?? '';
    final bankName = state.verificationResult?.bankName ?? "";
    final bankHolderName = state.verificationResult?.beneficiaryName ?? "";
    emit(state.copyWith(isSubmitting: true, clearSubmitError: true, clearVerifyError: true, clearVerifySuccess: true));

    final result = await addBankAccount(
      AddBankAccountParams(
        propertyId: propertyId,
        accountNumber: accountNumber,
        confirmAccountNumber: confirmAccountNumber,
        ifscCode: ifscCode,
        accountHolderName: bankHolderName,
        accountType: accountType,
        branchName: branchName,
        bankName: bankName,
        panNumber: panNumber,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(isSubmitting: false, submitError: failure.message)),
      (account) => emit(state.copyWith(isSubmitting: false, createdAccount: account)),
    );
  }

  Future<void> lookupIfscCode(String ifscCode) async {
    final trimmedCode = ifscCode.trim().toUpperCase();
    if (trimmedCode.length != 11) {
      emit(state.copyWith(
        isLookupLoading: false,
        clearLookupError: true,
        clearIfscLookupDetails: true,
      ));
      return;
    }

    emit(state.copyWith(
      isLookupLoading: true,
      clearLookupError: true,
      clearIfscLookupDetails: true,
    ));

    final result = await lookupIfsc(trimmedCode);

    result.fold(
      (failure) => emit(state.copyWith(
        isLookupLoading: false,
        lookupError: failure.message,
        clearIfscLookupDetails: true,
      )),
      (details) => emit(state.copyWith(
        isLookupLoading: false,
        ifscLookupDetails: details,
        clearLookupError: true,
      )),
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

  Future<void> verifyPan(String panNumber) async {
    emit(state.copyWith(isVerifyingPan: true, clearPanVerifyError: true, clearPanVerifySuccess: true));

    final result = await verifyPanUseCase(VerifyPanParams(panNumber: panNumber));

    result.fold(
      (failure) => emit(state.copyWith(isVerifyingPan: false, panVerifyError: failure.message)),
      (panVerificationResult) => emit(state.copyWith(
        isVerifyingPan: false,
        panVerifySuccess: true,
        panVerificationResult: panVerificationResult,
      )),
    );
  }
}
