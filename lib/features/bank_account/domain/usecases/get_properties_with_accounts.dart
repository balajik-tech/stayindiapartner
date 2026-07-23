import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/property_entity.dart';
import '../repositories/bank_account_repository.dart';

class GetPropertiesWithAccounts implements UseCase<List<PropertyEntity>, NoParams> {
  final BankAccountRepository repository;
  const GetPropertiesWithAccounts(this.repository);

  @override
  Future<Either<Failure, List<PropertyEntity>>> call(NoParams params) {
    return repository.getProperties();
  }
}
