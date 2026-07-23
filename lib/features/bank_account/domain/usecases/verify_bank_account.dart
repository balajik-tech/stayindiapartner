import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/bank_account_verification_result.dart';
import '../repositories/bank_account_repository.dart';

class VerifyBankAccountParams {
  final String accountNumber;
  final String ifscCode;
  final String clientRefNum;

  VerifyBankAccountParams({
    required this.accountNumber,
    required this.ifscCode,
    required this.clientRefNum,
  });
}

class VerifyBankAccount implements UseCase<BankAccountVerificationResult, VerifyBankAccountParams> {
  final BankAccountRepository repository;

  const VerifyBankAccount(this.repository);

  @override
  Future<Either<Failure, BankAccountVerificationResult>> call(VerifyBankAccountParams params) {
    return repository.verifyBankAccount(
      accountNumber: params.accountNumber,
      ifscCode: params.ifscCode,
      clientRefNum: params.clientRefNum,
    );
  }
}
