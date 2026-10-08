import 'dart:io';
import '../entities/tenant_entity.dart';

abstract class TenantRepository {
  Future<List<TenantEntity>> getTenants({
    String status = 'CHECKED_IN',
    int page = 1,
    int limit = 100,
    String? search,
    String? hostelId,
  });

  Future<TenantDetailEntity> getTenantDetail(String tenantId, String hostelId);

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
    double? totalAmount
  });

  Future<Map<String, dynamic>> bulkUploadTenants(File file, String hostelId);
}
