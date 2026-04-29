import 'package:stayindia_owner/features/staff/domain/entities/staff.dart';
import 'package:stayindia_owner/features/staff/domain/repositories/staff_repository.dart';
import '../datasources/staff_remote_datasource.dart';

class StaffRepositoryImpl implements StaffRepository {
  final StaffRemoteDataSource remoteDataSource;

  StaffRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Staff>> getStaff(String? hostelId) {
    return remoteDataSource.getStaff(hostelId);
  }

  @override
  Future<Staff> getStaffById(String id) {
    return remoteDataSource.getStaffById(id);
  }

  @override
  Future<void> createStaff({
    required String hostelId,
    required String name,
    required String phone,
    String? email,
    required String role,
    Map<String, dynamic>? permissions,
  }) {
    return remoteDataSource.createStaff(
      hostelId: hostelId,
      name: name,
      phone: phone,
      email: email,
      role: role,
      permissions: permissions,
    );
  }

  @override
  Future<void> updateStaff(String id, Map<String, dynamic> data) {
    return remoteDataSource.updateStaff(id, data);
  }

  @override
  Future<void> logActivity(String id, String action, String? details) {
    return remoteDataSource.logActivity(id, action, details);
  }
}
