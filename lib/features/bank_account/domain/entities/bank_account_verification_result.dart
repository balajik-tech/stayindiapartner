import 'package:equatable/equatable.dart';

class BankAccountVerificationResult extends Equatable {
  final String status;
  final String beneficiaryName;
  final String accountNumber;
  final String ifscCode;
  final String rrn;
  final String bankName;
  final String branchName;

  const BankAccountVerificationResult({
    required this.status,
    required this.beneficiaryName,
    required this.accountNumber,
    required this.ifscCode,
    required this.rrn,
    required this.bankName,
    required this.branchName,
  });

  factory BankAccountVerificationResult.fromJson(Map<String, dynamic> json) {
    return BankAccountVerificationResult(
      status: json['status']?.toString() ?? '',
      beneficiaryName: json['beneficiary_name']?.toString() ?? json['beneficiaryName']?.toString() ?? '',
      accountNumber: json['account_number']?.toString() ?? json['accountNumber']?.toString() ?? '',
      ifscCode: json['ifsc_code']?.toString() ?? json['ifsc_code']?.toString() ?? '',
      rrn: json['rrn']?.toString() ?? '',
      bankName: json['bank_name']?.toString() ?? json['bankName']?.toString() ?? '',
      branchName: json['branch_name']?.toString() ?? json['branchName']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [status, beneficiaryName, accountNumber, ifscCode, rrn, bankName, branchName];
}
