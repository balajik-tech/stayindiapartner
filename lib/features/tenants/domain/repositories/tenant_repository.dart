import '../entities/tenant_entity.dart';

abstract class TenantRepository {
  Future<List<TenantEntity>> getTenants({
    String status = 'CHECKED_IN',
    int page = 1,
    int limit = 100, 
    String? search,
  });

  Future<TenantDetailEntity> getTenantDetail(String tenantId, String hostelId);

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
