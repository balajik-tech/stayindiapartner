part of 'add_bank_account_cubit.dart';

class AddBankAccountState extends Equatable {
  final bool isIfscLoading;
  final BankBranchDetails? branchDetails;
  final String? ifscError;

  final bool isSubmitting;
  final String? submitError;
  final BankAccountEntity? createdAccount;

  const AddBankAccountState({
    this.isIfscLoading = false,
    this.branchDetails,
    this.ifscError,
    this.isSubmitting = false,
    this.submitError,
    this.createdAccount,
  });

  bool get isSuccess => createdAccount != null;

  AddBankAccountState copyWith({
    bool? isIfscLoading,
    BankBranchDetails? branchDetails,
    String? ifscError,
    bool clearIfsc = false,
    bool? isSubmitting,
    String? submitError,
    bool clearSubmitError = false,
    BankAccountEntity? createdAccount,
  }) {
    return AddBankAccountState(
      isIfscLoading: isIfscLoading ?? this.isIfscLoading,
      branchDetails: clearIfsc ? null : (branchDetails ?? this.branchDetails),
      ifscError: clearIfsc ? null : (ifscError ?? this.ifscError),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
      createdAccount: createdAccount ?? this.createdAccount,
    );
  }

  @override
  List<Object?> get props =>
      [isIfscLoading, branchDetails, ifscError, isSubmitting, submitError, createdAccount];
}
