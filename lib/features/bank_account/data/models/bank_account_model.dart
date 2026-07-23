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

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      id: json['id'] as String,
      propertyId: json['propertyId'] as String,
      bankName: json['bankName'] as String,
      branchName: json['branchName'] as String? ?? '',
      accountNumber: json['accountNumber'] as String,
      ifscCode: json['ifscCode'] as String,
      accountHolderName: json['accountHolderName'] as String,
      accountType: BankAccountType.values.firstWhere(
        (e) => e.name == json['accountType'],
        orElse: () => BankAccountType.savings,
      ),
      isPrimary: json['isPrimary'] as bool? ?? false,
      verificationStatus: AccountVerificationStatus.values.firstWhere(
        (e) => e.name == json['verificationStatus'],
        orElse: () => AccountVerificationStatus.pending,
      ),
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
