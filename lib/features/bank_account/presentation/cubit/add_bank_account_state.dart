part of 'add_bank_account_cubit.dart';

class AddBankAccountState extends Equatable {
  final bool isSubmitting;
  final bool isVerifying;
  final String? submitError;
  final String? verifyError;
  final bool verifySuccess;
  final BankAccountVerificationResult? verificationResult;
  final BankAccountEntity? createdAccount;

  const AddBankAccountState({
    this.isSubmitting = false,
    this.isVerifying = false,
    this.submitError,
    this.verifyError,
    this.verifySuccess = false,
    this.verificationResult,
    this.createdAccount,
  });

  bool get isSuccess => createdAccount != null;

  AddBankAccountState copyWith({
    bool? isSubmitting,
    bool? isVerifying,
    String? submitError,
    String? verifyError,
    bool? verifySuccess,
    bool clearSubmitError = false,
    bool clearVerifyError = false,
    bool clearVerifySuccess = false,
    BankAccountVerificationResult? verificationResult,
    BankAccountEntity? createdAccount,
  }) {
    return AddBankAccountState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isVerifying: isVerifying ?? this.isVerifying,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
      verifyError: clearVerifyError ? null : (verifyError ?? this.verifyError),
      verifySuccess: verifySuccess ?? (clearVerifySuccess ? false : this.verifySuccess),
      verificationResult: verificationResult ?? this.verificationResult,
      createdAccount: createdAccount ?? this.createdAccount,
    );
  }

  @override
  List<Object?> get props => [isSubmitting, isVerifying, submitError, verifyError, verifySuccess, verificationResult, createdAccount];
}
