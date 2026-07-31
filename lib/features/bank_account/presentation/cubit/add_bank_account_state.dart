part of 'add_bank_account_cubit.dart';


class AddBankAccountState extends Equatable {
  final bool isSubmitting;
  final bool isVerifying;
  final bool isLookupLoading;
  final bool isVerifyingPan;
  final String? submitError;
  final String? verifyError;
  final String? lookupError;
  final String? panVerifyError;
  final bool verifySuccess;
  final bool panVerifySuccess;
  final BankBranchDetails? ifscLookupDetails;
  final BankAccountVerificationResult? verificationResult;
  final PanVerificationResult? panVerificationResult;
  final BankAccountEntity? createdAccount;

  const AddBankAccountState({
    this.isSubmitting = false,
    this.isVerifying = false,
    this.isLookupLoading = false,
    this.isVerifyingPan = false,
    this.submitError,
    this.verifyError,
    this.lookupError,
    this.panVerifyError,
    this.verifySuccess = false,
    this.panVerifySuccess = false,
    this.ifscLookupDetails,
    this.verificationResult,
    this.panVerificationResult,
    this.createdAccount,
  });

  bool get isSuccess => createdAccount != null;

  AddBankAccountState copyWith({
    bool? isSubmitting,
    bool? isVerifying,
    bool? isLookupLoading,
    bool? isVerifyingPan,
    String? submitError,
    String? verifyError,
    String? lookupError,
    String? panVerifyError,
    bool? verifySuccess,
    bool? panVerifySuccess,
    bool clearSubmitError = false,
    bool clearVerifyError = false,
    bool clearLookupError = false,
    bool clearPanVerifyError = false,
    bool clearVerifySuccess = false,
    bool clearPanVerifySuccess = false,
    BankBranchDetails? ifscLookupDetails,
    bool clearIfscLookupDetails = false,
    BankAccountVerificationResult? verificationResult,
    PanVerificationResult? panVerificationResult,
    bool clearPanVerificationResult = false,
    BankAccountEntity? createdAccount,
  }) {
    return AddBankAccountState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isVerifying: isVerifying ?? this.isVerifying,
      isLookupLoading: isLookupLoading ?? this.isLookupLoading,
      isVerifyingPan: isVerifyingPan ?? this.isVerifyingPan,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
      verifyError: clearVerifyError ? null : (verifyError ?? this.verifyError),
      lookupError: clearLookupError ? null : (lookupError ?? this.lookupError),
      panVerifyError: clearPanVerifyError ? null : (panVerifyError ?? this.panVerifyError),
      verifySuccess: verifySuccess ?? (clearVerifySuccess ? false : this.verifySuccess),
      panVerifySuccess: panVerifySuccess ?? (clearPanVerifySuccess ? false : this.panVerifySuccess),
      ifscLookupDetails: clearIfscLookupDetails ? null : (ifscLookupDetails ?? this.ifscLookupDetails),
      verificationResult: verificationResult ?? this.verificationResult,
      panVerificationResult: clearPanVerificationResult ? null : (panVerificationResult ?? this.panVerificationResult),
      createdAccount: createdAccount ?? this.createdAccount,
    );
  }

  @override
  List<Object?> get props => [
        isSubmitting,
        isVerifying,
        isLookupLoading,
        isVerifyingPan,
        submitError,
        verifyError,
        lookupError,
        panVerifyError,
        verifySuccess,
        panVerifySuccess,
        ifscLookupDetails,
        verificationResult,
        panVerificationResult,
        createdAccount,
      ];
}
