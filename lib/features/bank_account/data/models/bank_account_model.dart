import '../../domain/entities/bank_account_entity.dart';

class BankAccountModel extends BankAccountEntity {
  const BankAccountModel({
    required super.id,
    required super.propertyId,
    required super.bankName,
    required super.branchName,
    required super.accountNumber,
    required super.ifscCode,
    required super.accountHolderName,
    required super.accountType,
    required super.isPrimary,
    required super.verificationStatus,
  });

  factory BankAccountModel.fromJson(
    Map<String, dynamic> json, {
    String? defaultPropertyId,
  }) {
    final accountTypeValue = json['accountType']?.toString() ?? '';
    final ifscValue = json['ifsc'] ?? json['ifscCode'] ?? '';
    final branchValue = (json['branchName'] as String?) ?? (json['branch'] as String?) ?? '';
    final bankNameValue = (json['bankName'] as String?) ?? branchValue;

    return BankAccountModel(
      id: (json['id'] ?? json['_id']) as String,
      propertyId: (json['propertyId'] ?? json['hostelId'] ?? defaultPropertyId) as String,
      bankName: bankNameValue,
      branchName: branchValue,
      accountNumber: json['accountNumber'] as String,
      ifscCode: ifscValue as String,
      accountHolderName: json['accountHolderName'] as String,
      accountType: _parseAccountType(accountTypeValue),
      isPrimary: (json['isPrimary'] as bool?) ?? (json['setAsPrimary'] as bool?) ?? false,
      verificationStatus: _parseVerificationStatus(json['isVerified'] ?? json['verificationStatus']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'propertyId': propertyId,
      'bankName': bankName,
      'branchName': branchName,
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,
      'accountHolderName': accountHolderName,
      'accountType': accountType.name,
      'isPrimary': isPrimary,
      'verificationStatus': verificationStatus.name,
    };
  }

  static BankAccountType _parseAccountType(String value) {
    final normalized = value.toLowerCase();
    if (normalized.contains('current')) return BankAccountType.current;
    return BankAccountType.savings;
  }

  static AccountVerificationStatus _parseVerificationStatus(dynamic value) {
    if (value is bool) {
      return value ? AccountVerificationStatus.verified : AccountVerificationStatus.pending;
    }
    if (value is String) {
      final normalized = value.toLowerCase();
      if (normalized.contains('verified')) return AccountVerificationStatus.verified;
      if (normalized.contains('failed')) return AccountVerificationStatus.failed;
    }
    return AccountVerificationStatus.pending;
  }



  factory BankAccountModel.fromEntity(BankAccountEntity e) {
    return BankAccountModel(
      id: e.id,
      propertyId: e.propertyId,
      bankName: e.bankName,
      branchName: e.branchName,
      accountNumber: e.accountNumber,
      ifscCode: e.ifscCode,
      accountHolderName: e.accountHolderName,
      accountType: e.accountType,
      isPrimary: e.isPrimary,
      verificationStatus: e.verificationStatus,
    );
  }
}
