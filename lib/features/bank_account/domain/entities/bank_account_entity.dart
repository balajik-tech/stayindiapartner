import 'package:equatable/equatable.dart';

enum BankAccountType { savings, current }

enum AccountVerificationStatus { verified, pending, failed }

enum EntityType {
  individual('INDIVIDUAL', 'Individual'),
  proprietorship('PROPRIETORSHIP', 'Proprietorship'),
  privatePublicLimited(
    'PRIVATE_PUBLIC_LIMITED',
    'Private Limited/Public Limited',
  ),
  partnership('PARTNERSHIP', 'Partnership'),
  llp('LLP', 'LLP'),
  huf('HUF', 'HUF');

  const EntityType(this.value, this.label);

  /// Value sent to / received from the API.
  final String value;

  /// Human-readable label for the UI.
  final String label;

  /// Parses an API value into an [EntityType]. Returns null if unknown.
  static EntityType? fromValue(String? value) {
    for (final type in EntityType.values) {
      if (type.value == value) return type;
    }
    return null;
  }
}

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
  final String businessType;
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
    required this.businessType,
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
      businessType: businessType ?? this.businessType,
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
