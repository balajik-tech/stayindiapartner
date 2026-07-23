import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/bank_account_repository.dart';

class SetPrimaryAccountParams extends Equatable {
  final String propertyId;
  final String accountId;

  const SetPrimaryAccountParams({required this.propertyId, required this.accountId});

  @override
  List<Object?> get props => [propertyId, accountId];
}

class SetPrimaryAccount implements UseCase<void, SetPrimaryAccountParams> {
  final BankAccountRepository repository;
  const SetPrimaryAccount(this.repository);

  @override
  Future<Either<Failure, void>> call(SetPrimaryAccountParams params) {
    return repository.setPrimaryAccount(
      propertyId: params.propertyId,
      accountId: params.accountId,
    );
  }
}
