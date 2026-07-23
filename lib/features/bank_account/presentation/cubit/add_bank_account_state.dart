part of 'add_bank_account_cubit.dart';

class AddBankAccountState extends Equatable {
  final bool isSubmitting;
  final String? submitError;
  final BankAccountEntity? createdAccount;

  const AddBankAccountState({
    this.isSubmitting = false,
    this.submitError,
    this.createdAccount,
  });

  bool get isSuccess => createdAccount != null;

  AddBankAccountState copyWith({
    bool? isSubmitting,
    String? submitError,
    bool clearSubmitError = false,
    BankAccountEntity? createdAccount,
  }) {
    return AddBankAccountState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
      createdAccount: createdAccount ?? this.createdAccount,
    );
  }

  @override
  List<Object?> get props => [isSubmitting, submitError, createdAccount];
}
