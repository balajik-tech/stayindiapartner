import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/kyc_result.dart';

abstract class DigiLockerRepository {
  /// Initiates DigiLocker verification with the given credentials and document types
  /// Returns Right(KycResult) on success, Left(Failure) on error
  Future<Either<Failure, KycResult>> verifyDocuments({
    required String companyName,
    required String secretToken,
    required String redirectUrl,
    required String documents,
    String panName = '',
    String panNo = '',
  });
}
