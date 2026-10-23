import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
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

  Future<Map<String, dynamic>> addManualTenant({
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
    String? userPhotoPath,
    String? aadharPhotoPath,
    String? aadharCardbackPath,
    String? employeeIdProofPath,
    List<Map<String, String>>? guardianMobiles,
    String? bookingType,
    String? maintenance,
    String? roomType,
    String? endDate,
    String? email,
    String? aadhaarNumber,
    String? dob,
    String? gender,
    String? address,
    double? totalAmount,
    bool? isexistingTenant,
  });

  Future<Map<String, dynamic>> bulkUploadTenants(File file, String hostelId);
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
      return await Isolate.run(
        () => items
            .map((j) => TenantModel.fromJson(j as Map<String, dynamic>))
            .toList(),
      );
    }
    throw Exception('Failed to fetch tenants');
  }

  @override
  Future<TenantDetailModel> getTenantDetail(
    String tenantId,
    String hostelId,
  ) async {
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
  Future<Map<String, dynamic>> addManualTenant({
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
    String? userPhotoPath,
    String? aadharPhotoPath,
    String? aadharCardbackPath,
    String? employeeIdProofPath,
    List<Map<String, String>>? guardianMobiles,
    String? bookingType,
    String? maintenance,
    String? roomType,
    String? endDate,
    String? email,
    String? aadhaarNumber,
    String? dob,
    String? gender,
    String? address,
    double? totalAmount,
    bool? isexistingTenant,
  }) async {
    AppLogger.info('Adding manual tenant for hostel: $hostelId');
    final map = <String, dynamic>{
      'phone': phone,
      'hostelId': hostelId,
      'roomId': roomId,
      'bedNumber': bedNumber,
      'rent': rent,
    };
    if (email != null && email.trim().isNotEmpty) {
      map['email'] = email.trim();
    }
    if (firstName != null && firstName.isNotEmpty) map['firstName'] = firstName;
    if (lastName != null && lastName.isNotEmpty) map['lastName'] = lastName;
    if (sharingType != null && sharingType.isNotEmpty) {
      map['sharingType'] = sharingType;
    }
    if (startDate != null && startDate.isNotEmpty) map['startDate'] = startDate;
    if (deposit != null) map['deposit'] = deposit;

    if (bookingType != null) map['bookingType'] = bookingType;
    if (maintenance != null && maintenance != "") map['maintenance'] = maintenance;
    if (roomType != null  && roomType != "") map['roomType'] = roomType;
    if (endDate != null  && endDate != "") map['endDate'] = endDate;

    if (aadhaarNumber != null) map['aadharNumber'] = aadhaarNumber;
    if (dob != null) map['dob'] = dob;
    if (gender != null) map['gender'] = gender;
    if (address != null) map['address'] = address;
    if(totalAmount != null) map['totalAmount'] = totalAmount;

    if (guardianMobiles != null && guardianMobiles.isNotEmpty) {
      map['guardianMobiles'] = jsonEncode(guardianMobiles);
    }

    final formData = FormData.fromMap(map);

    if (userPhotoPath != null && userPhotoPath.isNotEmpty) {
      formData.files.add(
        MapEntry(
          'avatar',
          await MultipartFile.fromFile(
            userPhotoPath,
            contentType: DioMediaType('image', 'jpeg'),
          ),
        ),
      );
    }

    if (aadharPhotoPath != null && aadharPhotoPath.isNotEmpty) {
      formData.files.add(
        MapEntry(
          'aadharCard',
          await MultipartFile.fromFile(
            aadharPhotoPath,
            contentType: DioMediaType('image', 'jpeg'),
          ),
        ),
      );
    }

    if (aadharCardbackPath != null && aadharCardbackPath.isNotEmpty) {
      formData.files.add(
        MapEntry(
          'aadharCardback',
          await MultipartFile.fromFile(
            aadharCardbackPath,
            contentType: DioMediaType('image', 'jpeg'),
          ),
        ),
      );
    }

    if (employeeIdProofPath != null && employeeIdProofPath.isNotEmpty) {
      formData.files.add(
        MapEntry(
          'employeeIdProof',
          await MultipartFile.fromFile(
            employeeIdProofPath,
            contentType: DioMediaType('image', 'jpeg'),
          ),
        ),
      );
    }

    debugPrint("========form fields========");
    for (final field in formData.fields) {
      debugPrint('${field.key}: ${field.value}');
    }

    for (final file in formData.files) {
      debugPrint('${file.key}: ${file.value.filename}');
    }
    debugPrint("========form fields========");

    var url = ApiConstants.tenantsManual;

    if (isexistingTenant == true) {
      url = ApiConstants.tenantsExistManual;
    } else {
      url = ApiConstants.tenantsManual;
    }
    debugPrint("========form fields========URL: $url");

    final response = await _dio.post(
      url,
      data: formData,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data as Map<String, dynamic>;
    } else {
      final msg = response.data?['message'] ?? 'Failed to add tenant';
      throw Exception(msg);
    }
  }

  @override
  Future<Map<String, dynamic>> bulkUploadTenants(File file, String hostelId) async {
    final fileName = file.path.split('/').last;
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
      ),
    });

    final response = await _dio.post(
      ApiConstants.bulkTenants(hostelId),
      data: formData,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return response.data as Map<String, dynamic>;
    }
    
    throw Exception(response.data?['message'] ?? 'Bulk upload failed');
  }
}
