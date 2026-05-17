import 'dart:isolate';
import 'package:dio/dio.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/core/utils/logger.dart';
import '../models/tenant_model.dart';

abstract class TenantRemoteDataSource {
  Future<List<TenantModel>> getTenants({
    String status = 'CHECKED_IN',
    int page = 1,
    int limit = 10,
    String? search,
    String? hostelId,
  });

  Future<TenantDetailModel> getTenantDetail(String tenantId, String hostelId);

  Future<void> addManualTenant({
    required String phone,
    required String hostelId,
    required String roomId,
    required String bedNumber,
    required double rent,
    String? firstName,
    String? lastName,
    String? sharingType,
    String? startDate,
    double? deposit,
  });
}

class TenantRemoteDataSourceImpl implements TenantRemoteDataSource {
  final Dio _dio;

  TenantRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<TenantModel>> getTenants({
    String status = 'CHECKED_IN',
    int page = 1,
    int limit = 10,
    String? search,
    String? hostelId,
  }) async {
    AppLogger.info('Fetching tenants list | Status: $status, Search: $search');
    final response = await _dio.get(
      ApiConstants.tenants,
      queryParameters: {
        'status': status,
        'page': page,
        'limit': limit,
        if (search?.isNotEmpty == true) 'search': search,
        if (hostelId?.isNotEmpty == true) 'hostelId': hostelId,
      },
    );

    if (response.statusCode == 200) {
      final raw = response.data;
      final data = (raw is Map && raw['data'] is Map)
          ? raw['data'] as Map<String, dynamic>
          : raw as Map<String, dynamic>;
      final items = (data['results'] ?? data['items']) as List<dynamic>? ?? [];
      return await Isolate.run(() => items.map((j) => TenantModel.fromJson(j as Map<String, dynamic>)).toList());
    }
    throw Exception('Failed to fetch tenants');
  }

  @override
  Future<TenantDetailModel> getTenantDetail(String tenantId, String hostelId) async {
    AppLogger.info('Fetching tenant detail | ID: $tenantId');
    final response = await _dio.get(
      '${ApiConstants.tenantDetail}/$tenantId',
      queryParameters: {'hostelId': hostelId},
    );

    if (response.statusCode == 200) {
      final raw = response.data;
      final data = (raw is Map && raw['data'] is Map)
          ? raw['data'] as Map<String, dynamic>
          : raw as Map<String, dynamic>;
      return await Isolate.run(() => TenantDetailModel.fromJson(data));
    }
    throw Exception('Failed to load tenant detail');
  }

  @override
  Future<void> addManualTenant({
    required String phone,
    required String hostelId,
    required String roomId,
    required String bedNumber,
    required double rent,
    String? firstName,
    String? lastName,
    String? sharingType,
    String? startDate,
    double? deposit,
  }) async {
    AppLogger.info('Adding manual tenant for hostel: $hostelId');
    final body = {
      'phone': phone,
      'hostelId': hostelId,
      'roomId': roomId,
      'bedNumber': bedNumber,
      'rent': rent,
      'firstName': firstName,
      'lastName': lastName,
      'sharingType': sharingType,
      'startDate': startDate,
      'deposit': deposit,
    }..removeWhere((key, value) => value == null || (value is String && value.isEmpty));

    final response = await _dio.post(ApiConstants.tenantsManual, data: body);
    if (response.statusCode != 200 && response.statusCode != 201) {
      final msg = response.data?['message'] ?? 'Failed to add tenant';
      throw Exception(msg);
    }
  }
}
