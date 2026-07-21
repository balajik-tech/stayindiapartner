import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/kyc_result.dart';
import '../repositories/digilocker_repository.dart';

class VerifyDocuments {
  final DigiLockerRepository repository;

  VerifyDocuments(this.repository);

  Future<Either<Failure, KycResult>> call({
    required String companyName,
    required String secretToken,
    required String redirectUrl,
    required String documents,
    String panName = '',
    String panNo = '',
  }) {
    return repository.verifyDocuments(
      companyName: companyName,
      secretToken: secretToken,
      redirectUrl: redirectUrl,
      documents: documents,
      panName: panName,
      panNo: panNo,
    );
  }
}
