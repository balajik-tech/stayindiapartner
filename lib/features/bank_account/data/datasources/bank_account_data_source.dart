import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../../domain/entities/bank_account_entity.dart';
import '../../domain/entities/bank_account_verification_result.dart';
import '../../domain/entities/bank_branch_details.dart';
import '../../domain/entities/pan_verification_result.dart';
import '../../domain/entities/property_entity.dart';
import '../../../../../core/constants/api_constants.dart';
import '../../../../../core/services/token_storage.dart';
import '../models/bank_account_model.dart';
import '../models/property_model.dart';

abstract class BankAccountDataSource {
  Future<List<PropertyModel>> getProperties();

  Future<BankAccountVerificationResult> verifyBankAccount({
    required String accountNumber,
    required String ifscCode,
    required String clientRefNum,
  });

  Future<BankAccountModel> addBankAccount({
    required String propertyId,
    required String accountNumber,
    required String ifscCode,
    required String accountHolderName,
    required BankAccountType accountType,
    String? branchName,
    String? bankName,
    required String pan,
    bool setAsPrimary = true,
    EntityType entityType = EntityType.individual,
  });

  Future<void> setPrimaryAccount({required String propertyId, required String accountId});

  Future<void> deleteBankAccount(String accountId);

  Future<BankBranchDetails> lookupIfsc(String ifscCode);

  Future<PanVerificationResult> verifyPan(String panNumber);
}

class BankAccountRemoteDataSourceImpl implements BankAccountDataSource {
  final Dio _dio;
  final TokenStorage _tokenStorage;

  BankAccountRemoteDataSourceImpl({required Dio dio, required TokenStorage tokenStorage})
      : _dio = dio,
        _tokenStorage = tokenStorage;

  @override
  Future<List<PropertyModel>> getProperties() async {
    final response = await _dio.get(ApiConstants.bankAccounts);
    final dynamic rawData = response.data['data'] ?? response.data;
    if (rawData is! List) {
      return [];
    }

    final List<PropertyModel> properties = [];
    for (final owner in rawData) {
      final hostels = (owner['hostels'] as List<dynamic>?) ?? [];
      for (final hostel in hostels) {
        properties.add(PropertyModel.fromJson(hostel as Map<String, dynamic>));
      }
    }
    return properties;
  }

  @override
  Future<BankAccountModel> addBankAccount({
    required String propertyId,
    required String accountNumber,
    required String ifscCode,
    required String accountHolderName,
    required BankAccountType accountType,
    String? branchName,
    String? bankName,
    required String pan,
    bool setAsPrimary = true,
    EntityType entityType = EntityType.individual,
  }) async {
    final payload = {
      'hostelId': propertyId,
      'accountHolderName': accountHolderName,
      'accountNumber': accountNumber,
      'accountType': accountType == BankAccountType.current ? 'Current' : 'Savings',
      'branch': branchName ?? '',
      'bankName': bankName ?? '',
      'ifsc': ifscCode,
      'isVerified': true,
      'setAsPrimary': setAsPrimary,
      'pan': pan,
      "subscriptionType": "HOSTEL",
      "businessType": entityType.value,
    };

    debugPrint("Bank Account payload: $payload");


    try {
      final response = await _dio.post(ApiConstants.bankAccounts, data: payload);
      final dynamic rawPayload = response.data;
      final Map<String, dynamic>? data = rawPayload is Map<String, dynamic>
          ? (rawPayload['data'] as Map<String, dynamic>?)
          : (rawPayload is Map
              ? Map<String, dynamic>.from(rawPayload['data'] ?? rawPayload)
              : null);

      if (data == null) {
        throw Exception('Bank account creation response was empty or malformed.');
      }

      return BankAccountModel.fromJson(data, defaultPropertyId: propertyId);
    } on DioException catch (e) {
      final responseData = e.response?.data;

      String errorMessage = 'Bank Account creation failed';

      if (responseData is Map) {
        errorMessage =
            responseData['message']?.toString() ??
                responseData['error']?.toString() ??
                responseData['detail']?.toString() ??
                errorMessage;
      } else if (responseData is String &&
          responseData.trim().isNotEmpty) {
        errorMessage = responseData;
      }

      throw Exception(errorMessage);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> setPrimaryAccount({required String propertyId, required String accountId}) async {
    await _dio.put('${ApiConstants.bankAccounts}/$accountId', data: {'setAsPrimary': true});
  }

  @override
  Future<void> deleteBankAccount(String accountId) async {
    await _dio.delete('${ApiConstants.bankAccounts}/$accountId');
  }

  @override
  Future<BankBranchDetails> lookupIfsc(String ifscCode) async {
    final response = await _dio.get(
      'https://ifsc.razorpay.com/$ifscCode',
      options: Options(
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    final raw = response.data;
    if (raw is! Map<String, dynamic>) {
      throw Exception('IFSC code not found');
    }

    final bankName = (raw['BANK'] ?? raw['BANK_NAME'] ?? raw['bank'] ?? '').toString().trim();
    final branchName = (raw['ADDRESS'] ?? raw['BRANCH'] ?? raw['branch'] ?? '').toString().trim();

    if (bankName.isEmpty && branchName.isEmpty) {
      throw Exception('IFSC code not found');
    }

    return BankBranchDetails(
      bankName: bankName,
      branchName: branchName,
    );
  }

  @override
  Future<BankAccountVerificationResult> verifyBankAccount({
    required String accountNumber,
    required String ifscCode,
    required String clientRefNum,
  }) async {
    final token = await _tokenStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Missing authorization token for bank account verification.');
    }

    final clientRef = '${clientRefNum}_CLIENT_${DateTime.now().millisecondsSinceEpoch}';

    final payload = {
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,
      'clientRefNum': clientRef,
    };

    final response = await _dio.post(
      ApiConstants.externalBankVerification,
      data: payload,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'jwt-token': ApiConstants.bankJwtToken,
        },
      ),
    );

    final raw = response.data;
    if (raw is! Map<String, dynamic> || raw['status'] != true) {
      final message = raw['message']?.toString() ?? 'Bank account verification failed.';
      throw Exception(message);
    }

    final result = raw['data'] as Map<String, dynamic>?;
    if (result == null || result['status']?.toString().toUpperCase() != 'SUCCESS') {
      final message = result?['status']?.toString() ?? 'Bank account verification did not succeed.';
      throw Exception(message);
    }

    return BankAccountVerificationResult.fromJson(result);
  }

  @override
  Future<PanVerificationResult> verifyPan(String panNumber) async {
    final payload = {
      'idNumber': panNumber,
    };

    final response = await _dio.post(
      ApiConstants.panVerification,
      data: payload,
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'jwt-token': ApiConstants.panJwtToken,
        },
      ),
    );

    final raw = response.data;
    if (raw is! Map<String, dynamic> || raw['status'] != true) {
      final message = raw['message']?.toString() ?? 'PAN verification failed.';
      throw Exception(message);
    }

    final result = raw['data'] as Map<String, dynamic>?;
    if (result == null) {
      throw Exception('PAN verification data not found.');
    }

    return PanVerificationResult.fromJson(result);
  }
}

