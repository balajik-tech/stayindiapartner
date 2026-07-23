import 'package:equatable/equatable.dart';

/// Result of looking up an IFSC code, e.g. "HDFC Bank, Koramangala 5th Block, Bengaluru"
class BankBranchDetails extends Equatable {
  final String bankName;
  final String branchName;

  const BankBranchDetails({required this.bankName, required this.branchName});

  String get displayLabel => '$bankName, $branchName';

  @override
  List<Object?> get props => [bankName, branchName];
}
