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
    required super.businessType,
    required super.accountType,
    required super.isPrimary,
    required super.verificationStatus,
  });

  factory BankAccountModel.fromJson(
    Map<String, dynamic> json, {
    String? defaultPropertyId,
  }) {
    final accountTypeValue = json['accountType']?.toString() ?? '';
    final ifscValue = (json['ifsc'] ?? json['ifscCode'] ?? '').toString();
    final branchValue = (json['branchName'] ?? json['branch'] ?? '').toString();
    final bankNameValue = (json['bankName'] ?? branchValue).toString();
    final rawPropertyId = json['propertyId'] ?? json['hostelId'] ?? defaultPropertyId;
    final propertyIdValue = _toIdString(rawPropertyId, fallback: defaultPropertyId ?? '');
    final rawAccountId = json['id'] ?? json['_id'];

    return BankAccountModel(
      id: _toIdString(rawAccountId, fallback: ''),
      propertyId: propertyIdValue,
      bankName: bankNameValue,
      branchName: branchValue,
      accountNumber: (json['accountNumber'] ?? '').toString(),
      ifscCode: ifscValue,
      accountHolderName: (json['accountHolderName'] ?? '').toString(),
      businessType: (json['businessType'] ?? '').toString(),
      accountType: _parseAccountType(accountTypeValue),
      isPrimary: (json['isPrimary'] as bool?) ?? (json['setAsPrimary'] as bool?) ?? false,
      verificationStatus: _parseVerificationStatus(json['isVerified'] ?? json['verificationStatus']),
    );
  }

  static String _toIdString(dynamic value, {required String fallback}) {
    if (value == null) return fallback;
    if (value is Map) {
      final nestedId = value['_id'] ?? value['id'];
      return nestedId?.toString() ?? fallback;
    }
    return value.toString();
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
      "businessType":businessType,
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
      businessType: e.businessType,
      accountType: e.accountType,
      isPrimary: e.isPrimary,
      verificationStatus: e.verificationStatus,
    );
  }
}
