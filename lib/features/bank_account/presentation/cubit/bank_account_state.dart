part of 'bank_account_cubit.dart';

abstract class BankAccountState extends Equatable {
  const BankAccountState();

  @override
  List<Object?> get props => [];
}

class BankAccountInitial extends BankAccountState {
  const BankAccountInitial();
}

class BankAccountLoading extends BankAccountState {
  const BankAccountLoading();
}

class BankAccountLoaded extends BankAccountState {
  final List<PropertyEntity> properties;
  /// accountId currently being set as primary, so its tile can show a spinner.
  final String? updatingAccountId;

  const BankAccountLoaded(this.properties, {this.updatingAccountId});

  int get totalAccounts => properties.fold(0, (sum, p) => sum + p.accounts.length);

  BankAccountLoaded copyWith({List<PropertyEntity>? properties, String? updatingAccountId}) {
    return BankAccountLoaded(
      properties ?? this.properties,
      updatingAccountId: updatingAccountId,
    );
  }

  @override
  List<Object?> get props => [properties, updatingAccountId];
}

class BankAccountError extends BankAccountState {
  final String message;
  const BankAccountError(this.message);

  @override
  List<Object?> get props => [message];
}
