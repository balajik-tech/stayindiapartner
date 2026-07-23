import 'package:dio/dio.dart';

import '../../domain/entities/bank_account_entity.dart';
import '../../domain/entities/bank_branch_details.dart';
import '../../domain/entities/property_entity.dart';
import '../../../../../core/constants/api_constants.dart';
import '../models/bank_account_model.dart';
import '../models/property_model.dart';

abstract class BankAccountDataSource {
  Future<List<PropertyModel>> getProperties();

  Future<BankAccountModel> addBankAccount({
    required String propertyId,
    required String accountNumber,
    required String ifscCode,
    required String accountHolderName,
    required BankAccountType accountType,
    String? branchName,
    bool setAsPrimary = true,
  });

  Future<void> setPrimaryAccount({required String propertyId, required String accountId});

  Future<BankBranchDetails> lookupIfsc(String ifscCode);
}

class BankAccountRemoteDataSourceImpl implements BankAccountDataSource {
  final Dio _dio;

  BankAccountRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

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
    bool setAsPrimary = true,
  }) async {
    final payload = {
      'hostelId': propertyId,
      'accountHolderName': accountHolderName,
      'accountNumber': accountNumber,
      'accountType': accountType == BankAccountType.current ? 'Current' : 'Savings',
      'branch': branchName ?? '',
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
        final accounts = (hostel['accounts'] as List<dynamic>?) ?? [];
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
}

