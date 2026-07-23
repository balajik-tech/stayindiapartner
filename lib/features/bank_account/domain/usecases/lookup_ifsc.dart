import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/bank_branch_details.dart';
import '../repositories/bank_account_repository.dart';

class LookupIfsc implements UseCase<BankBranchDetails, String> {
  final BankAccountRepository repository;
  const LookupIfsc(this.repository);

  @override
  Future<Either<Failure, BankBranchDetails>> call(String ifscCode) {
    if (ifscCode.trim().length != 11) {
      return Future.value(const Left(ValidationFailure(message: 'Enter a valid 11-character IFSC code.')));
    }
    return repository.lookupIfsc(ifscCode.toUpperCase());
  }
}
