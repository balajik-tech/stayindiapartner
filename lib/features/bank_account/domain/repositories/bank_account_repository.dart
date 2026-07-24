import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/bank_account_entity.dart';
import '../entities/bank_account_verification_result.dart';
import '../entities/bank_branch_details.dart';
import '../entities/property_entity.dart';

abstract class BankAccountRepository {
  /// Returns every property owned by the host along with its linked bank accounts.
  Future<Either<Failure, List<PropertyEntity>>> getProperties();

  /// Adds a new bank account under [propertyId] and kicks off penny-drop verification.
  Future<Either<Failure, BankAccountEntity>> addBankAccount({
    required String propertyId,
    required String accountNumber,
    required String ifscCode,
    required String accountHolderName,
    required BankAccountType accountType,
    String? branchName,
    String? bankName,
  });

  Future<Either<Failure, BankAccountVerificationResult>> verifyBankAccount({
    required String accountNumber,
    required String ifscCode,
    required String clientRefNum,
  });

  /// Marks [accountId] as the primary payout account for [propertyId].
  Future<Either<Failure, void>> setPrimaryAccount({
    required String propertyId,
    required String accountId,
  });

  /// Deletes a bank account by [accountId].
  Future<Either<Failure, void>> deleteBankAccount(String accountId);

  /// Resolves bank + branch name from an IFSC code, used to show the
  /// confirmation chip under the IFSC field while adding an account.
  Future<Either<Failure, BankBranchDetails>> lookupIfsc(String ifscCode);
}
