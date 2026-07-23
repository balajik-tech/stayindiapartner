import 'package:dio/dio.dart';

import '../../domain/entities/bank_account_entity.dart';
import '../../domain/entities/bank_account_verification_result.dart';
import '../../domain/entities/bank_branch_details.dart';
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
    bool setAsPrimary = true,
  });

  Future<void> setPrimaryAccount({required String propertyId, required String accountId});

  Future<BankBranchDetails> lookupIfsc(String ifscCode);
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
    bool setAsPrimary = true,
  }) async {
    final payload = {
      'hostelId': propertyId,
      'accountHolderName': accountHolderName,
      'accountNumber': accountNumber,
      'accountType': accountType == BankAccountType.current ? 'Current' : 'Savings',
      'branch': branchName ?? '',
      'bankName': bankName ?? '',
      'ifsc': ifscCode,
      'isVerified': false,
      'setAsPrimary': setAsPrimary,
    };

    final response = await _dio.post(ApiConstants.bankAccounts, data: payload);
    final data = response.data['data'] ?? response.data;
    return BankAccountModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> setPrimaryAccount({required String propertyId, required String accountId}) async {
    await _dio.put('${ApiConstants.bankAccounts}/$accountId', data: {'setAsPrimary': true});
  }

  @override
  Future<BankBranchDetails> lookupIfsc(String ifscCode) async {
    final response = await _dio.get(ApiConstants.bankAccounts);
    final dynamic rawData = response.data['data'] ?? response.data;
    if (rawData is! List) {
      throw Exception('IFSC code not found');
    }

    for (final owner in rawData) {
      final hostels = (owner['hostels'] as List<dynamic>?) ?? [];
      for (final hostel in hostels) {
        final accounts = (hostel['bankAccounts'] as List<dynamic>?) ?? [];
        for (final account in accounts) {
          final accountJson = account as Map<String, dynamic>;
          final accountIfsc = (accountJson['ifsc'] ?? accountJson['ifscCode'])?.toString();
          if (accountIfsc == ifscCode) {
            return BankBranchDetails(
              bankName: (accountJson['bankName'] as String?) ?? '',
              branchName: (accountJson['branchName'] as String?) ?? (accountJson['branch'] as String?) ?? '',
            );
          }
        }
      }
    }

    throw Exception('IFSC code not found');
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

    final payload = {
      'account_number': accountNumber,
      'ifsc_code': ifscCode,
      'clientRefNum': clientRefNum,
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
}

