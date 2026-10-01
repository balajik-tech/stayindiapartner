import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/bank_account_entity.dart';
import '../repositories/bank_account_repository.dart';

class AddBankAccountParams extends Equatable {
  final String propertyId;
  final String accountNumber;
  final String confirmAccountNumber;
  final String ifscCode;
  final String accountHolderName;
  final BankAccountType accountType;
  final String? branchName;
  final String? bankName;
  final String panNumber;
  final EntityType entityType;

  const AddBankAccountParams({
    required this.propertyId,
    required this.accountNumber,
    required this.confirmAccountNumber,
    required this.ifscCode,
    required this.accountHolderName,
    required this.accountType,
    this.branchName,
    this.bankName,
    required this.panNumber,
    this.entityType = EntityType.individual,
  });

  @override
  List<Object?> get props =>
      [propertyId, accountNumber, confirmAccountNumber, ifscCode, accountHolderName, accountType, branchName, bankName, panNumber, entityType];
}

class AddBankAccount implements UseCase<BankAccountEntity, AddBankAccountParams> {
  final BankAccountRepository repository;
  const AddBankAccount(this.repository);

  @override
  Future<Either<Failure, BankAccountEntity>> call(AddBankAccountParams params) async {
    if (params.accountNumber.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Enter an account number.'));
    }
    if (params.accountNumber != params.confirmAccountNumber) {
      return const Left(ValidationFailure(message: 'Account numbers do not match.'));
    }
    if (params.ifscCode.trim().length != 11) {
      return const Left(ValidationFailure(message: 'Enter a valid 11-character IFSC code.'));
    }
    if (params.accountHolderName.trim().isEmpty) {
      return const Left(ValidationFailure(message: 'Enter the account holder name.'));
    }

    return repository.addBankAccount(
      propertyId: params.propertyId,
      accountNumber: params.accountNumber,
      ifscCode: params.ifscCode.toUpperCase(),
      accountHolderName: params.accountHolderName,
      accountType: params.accountType,
      branchName: params.branchName,
      bankName: params.bankName,
      pan: params.panNumber,
      entityType: params.entityType,
    );
  }
}
