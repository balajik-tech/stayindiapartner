import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/kyc_result.dart';
import '../../domain/repositories/digilocker_repository.dart';


class DigiLockerRepositoryImpl implements DigiLockerRepository {
  static const String _kycResultKey = 'digi_locker_details_tenant';

  @override
  Future<Either<Failure, KycResult>> verifyDocuments({
    required String companyName,
    required String secretToken,
    required String redirectUrl,
    required String documents,
    String panName = '',
    String panNo = '',
  }) async {
    try {
      // Note: This is a placeholder implementation.
      // The actual verification happens through the UI flow using DigiLockerWidget.
      // This repository can be used for backend validation or additional processing.

      // For now, we return a success with a placeholder result
      // In a real implementation, you might call a backend API to validate the result
      return Right(KycResult(
        capturedAt: DateTime.now(),
      ));
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Failed to verify documents: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, void>> saveKycResult(KycResult result) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_kycResultKey, jsonEncode(result.toJson()));
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Failed to save KYC result: ${e.toString()}',
      ));
    }
  }

  @override
  Future<Either<Failure, KycResult?>> loadKycResult() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_kycResultKey);

      if (jsonString == null) {
        return const Right(null);
      }

      final result = KycResult.fromJson(jsonDecode(jsonString));
      return Right(result);
    } catch (e) {
      return Left(UnknownFailure(
        message: 'Failed to load KYC result: ${e.toString()}',
      ));
    }
  }
}
