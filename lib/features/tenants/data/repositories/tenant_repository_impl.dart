import 'package:stayindia_owner/features/tenants/domain/entities/tenant_entity.dart';
import 'package:stayindia_owner/features/tenants/domain/repositories/tenant_repository.dart';
import 'package:stayindia_owner/features/tenants/data/datasources/tenant_remote_datasource.dart';

class TenantRepositoryImpl implements TenantRepository {
  final TenantRemoteDataSource remote;

  TenantRepositoryImpl({required this.remote});

  @override
  Future<List<TenantEntity>> getTenants({
    String status = 'CHECKED_IN',
    int page = 1,
    int limit = 10,
    String? search,
    String? hostelId,
  }) => remote.getTenants(
    status: status,
    page: page,
    limit: limit,
    search: search,
    hostelId: hostelId,
  );

  @override
  Future<TenantDetailEntity> getTenantDetail(
    String tenantId,
    String hostelId,
  ) => remote.getTenantDetail(tenantId, hostelId);

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
    String? userPhotoPath,
    String? aadharPhotoPath,
    String? aadharCardbackPath,
    String? bookingType,
    String? maintenance,
    String? roomType,
    String? endDate,
    String? email
  }) => remote.addManualTenant(
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
    aadharCardbackPath: aadharCardbackPath,
    bookingType:bookingType,
    maintenance:maintenance,
    roomType:roomType,
    endDate:endDate,
    email:email
  );
}
