import 'package:stayindia_owner/features/tenants/domain/entities/tenant_entity.dart';
import 'package:stayindia_owner/features/tenants/domain/repositories/tenant_repository.dart';

class GetTenantsUseCase {
  final TenantRepository repository;
  GetTenantsUseCase(this.repository);

  Future<List<TenantEntity>> call({
    String status = 'CHECKED_IN',
    int page = 1,
    int limit = 10,
    String? search,
    String? hostelId,
  }) {
    return repository.getTenants(
      status: status,
      page: page,
      limit: limit,
      search: search,
      hostelId: hostelId,
    );
  }
}

class GetTenantsForHostelUseCase {
  final TenantRepository repository;
  GetTenantsForHostelUseCase(this.repository);

  Future<List<TenantEntity>> call(String hostelId) {
    return repository
        .getTenants(status: 'CHECKED_IN', limit: 200, hostelId: hostelId)
        .then((all) => all.where((t) => t.hostelId == hostelId).toList());
  }
}

class GetTenantDetailUseCase {
  final TenantRepository repository;
  GetTenantDetailUseCase(this.repository);

  Future<TenantDetailEntity> call(String tenantId, String hostelId) {
    return repository.getTenantDetail(tenantId, hostelId);
  }
}

class AddTenantUseCase {
  final TenantRepository repository;
  AddTenantUseCase(this.repository);

  Future<void> call({
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
    String? bookingType,
    String? maintenance,
    String? roomType,
    String? endDate
  }) {
    return repository.addManualTenant(
      phone: phone,
      hostelId: hostelId,
      roomId: roomId,
      bedNumber: bedNumber,
      rent: rent,
      firstName: firstName,
      lastName: lastName,
      sharingType: sharingType,
      startDate: startDate,
      deposit: deposit,
      userPhotoPath: userPhotoPath,
      aadharPhotoPath: aadharPhotoPath,
      bookingType:bookingType,
        maintenance:maintenance,
        roomType:roomType,
        endDate:endDate
    );
  }
}
