import 'package:equatable/equatable.dart';

enum BankAccountType { savings, current }

enum AccountVerificationStatus { verified, pending, failed }

extension BankAccountTypeX on BankAccountType {
  String get label => this == BankAccountType.savings ? 'Savings' : 'Current';
}

class BankAccountEntity extends Equatable {
  final String id;
  final String propertyId;
  final String bankName;
  final String branchName;
  final String accountNumber;
  final String ifscCode;
  final String accountHolderName;
  final BankAccountType accountType;
  final bool isPrimary;
  final AccountVerificationStatus verificationStatus;

  const BankAccountEntity({
    required this.id,
    required this.propertyId,
    required this.bankName,
    required this.branchName,
    required this.accountNumber,
    required this.ifscCode,
    required this.accountHolderName,
    required this.accountType,
    required this.isPrimary,
    required this.verificationStatus,
  });

  /// e.g. "••4821"
  String get maskedAccountNumber {
    if (accountNumber.length <= 4) return accountNumber;
    return '••${accountNumber.substring(accountNumber.length - 4)}';
  }

  BankAccountEntity copyWith({
    String? id,
    String? propertyId,
    String? bankName,
    String? branchName,
    String? accountNumber,
    String? ifscCode,
    String? accountHolderName,
    BankAccountType? accountType,
    bool? isPrimary,
    AccountVerificationStatus? verificationStatus,
  }) {
    return BankAccountEntity(
      id: id ?? this.id,
      propertyId: propertyId ?? this.propertyId,
      bankName: bankName ?? this.bankName,
      branchName: branchName ?? this.branchName,
      accountNumber: accountNumber ?? this.accountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      accountType: accountType ?? this.accountType,
      isPrimary: isPrimary ?? this.isPrimary,
      verificationStatus: verificationStatus ?? this.verificationStatus,
    );
  }

  @override
  List<Object?> get props => [
        id,
        propertyId,
        bankName,
        branchName,
        accountNumber,
        ifscCode,
        accountHolderName,
        accountType,
        isPrimary,
        verificationStatus,
      ];
}
