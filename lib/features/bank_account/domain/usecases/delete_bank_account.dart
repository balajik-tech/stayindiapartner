import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/bank_account_repository.dart';

class DeleteBankAccount implements UseCase<void, String> {
  final BankAccountRepository repository;

  const DeleteBankAccount(this.repository);

  @override
  Future<Either<Failure, void>> call(String accountId) {
    return repository.deleteBankAccount(accountId);
  }
}
