part of 'add_bank_account_cubit.dart';

class AddBankAccountState extends Equatable {
  final bool isSubmitting;
  final bool isVerifying;
  final bool isLookupLoading;
  final String? submitError;
  final String? verifyError;
  final String? lookupError;
  final bool verifySuccess;
  final BankBranchDetails? ifscLookupDetails;
  final BankAccountVerificationResult? verificationResult;
  final BankAccountEntity? createdAccount;

  const AddBankAccountState({
    this.isSubmitting = false,
    this.isVerifying = false,
    this.isLookupLoading = false,
    this.submitError,
    this.verifyError,
    this.lookupError,
    this.verifySuccess = false,
    this.ifscLookupDetails,
    this.verificationResult,
    this.createdAccount,
  });

  bool get isSuccess => createdAccount != null;

  AddBankAccountState copyWith({
    bool? isSubmitting,
    bool? isVerifying,
    bool? isLookupLoading,
    String? submitError,
    String? verifyError,
    String? lookupError,
    bool? verifySuccess,
    bool clearSubmitError = false,
    bool clearVerifyError = false,
    bool clearLookupError = false,
    bool clearVerifySuccess = false,
    BankBranchDetails? ifscLookupDetails,
    bool clearIfscLookupDetails = false,
    BankAccountVerificationResult? verificationResult,
    BankAccountEntity? createdAccount,
  }) {
    return AddBankAccountState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isVerifying: isVerifying ?? this.isVerifying,
      isLookupLoading: isLookupLoading ?? this.isLookupLoading,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
      verifyError: clearVerifyError ? null : (verifyError ?? this.verifyError),
      lookupError: clearLookupError ? null : (lookupError ?? this.lookupError),
      verifySuccess: verifySuccess ?? (clearVerifySuccess ? false : this.verifySuccess),
      ifscLookupDetails: clearIfscLookupDetails ? null : (ifscLookupDetails ?? this.ifscLookupDetails),
      verificationResult: verificationResult ?? this.verificationResult,
      createdAccount: createdAccount ?? this.createdAccount,
    );
  }

  @override
  List<Object?> get props => [isSubmitting, isVerifying, isLookupLoading, submitError, verifyError, lookupError, verifySuccess, ifscLookupDetails, verificationResult, createdAccount];
}
