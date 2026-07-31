import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/pan_verification_result.dart';
import '../repositories/bank_account_repository.dart';

class VerifyPanParams {
  final String panNumber;

  VerifyPanParams({
    required this.panNumber,
  });
}

class VerifyPan implements UseCase<PanVerificationResult, VerifyPanParams> {
  final BankAccountRepository repository;

  const VerifyPan(this.repository);

  @override
  Future<Either<Failure, PanVerificationResult>> call(VerifyPanParams params) {
    return repository.verifyPan(params.panNumber);
  }
}
