import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/bank_account_entity.dart';
import '../../domain/entities/bank_account_verification_result.dart';
import '../../domain/entities/bank_branch_details.dart';
import '../../domain/entities/pan_verification_result.dart';
import '../../domain/entities/property_entity.dart';
import '../../domain/repositories/bank_account_repository.dart';
import '../datasources/bank_account_data_source.dart';

class BankAccountRepositoryImpl implements BankAccountRepository {
  final BankAccountDataSource dataSource;
  const BankAccountRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<PropertyEntity>>> getProperties() async {
    try {
      final properties = await dataSource.getProperties();
      return Right(properties);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BankAccountEntity>> addBankAccount({
    required String propertyId,
    required String accountNumber,
    required String ifscCode,
    required String accountHolderName,
    required BankAccountType accountType,
    String? branchName,
    String? bankName,
    required String pan,
  }) async {
    try {
      final account = await dataSource.addBankAccount(
        propertyId: propertyId,
        accountNumber: accountNumber,
        ifscCode: ifscCode,
        accountHolderName: accountHolderName,
        accountType: accountType,
        branchName: branchName,
        bankName: bankName,
        pan: pan,
      );
      return Right(account);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> setPrimaryAccount({
    required String propertyId,
    required String accountId,
  }) async {
    try {
      await dataSource.setPrimaryAccount(propertyId: propertyId, accountId: accountId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBankAccount(String accountId) async {
    try {
      await dataSource.deleteBankAccount(accountId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BankAccountVerificationResult>> verifyBankAccount({
    required String accountNumber,
    required String ifscCode,
    required String clientRefNum,
  }) async {
    try {
      final result = await dataSource.verifyBankAccount(
        accountNumber: accountNumber,
        ifscCode: ifscCode,
        clientRefNum: clientRefNum,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, BankBranchDetails>> lookupIfsc(String ifscCode) async {
    try {
      final details = await dataSource.lookupIfsc(ifscCode);
      return Right(details);
    } catch (e) {
      return Left(ServerFailure(message: 'IFSC code not found'));
    }
  }

  @override
  Future<Either<Failure, PanVerificationResult>> verifyPan(String panNumber) async {
    try {
      final result = await dataSource.verifyPan(panNumber);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
