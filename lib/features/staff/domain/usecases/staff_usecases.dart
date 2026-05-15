import 'package:stayindia_owner/features/staff/domain/entities/staff.dart';
import 'package:stayindia_owner/features/staff/domain/repositories/staff_repository.dart';

class GetStaffListUseCase {
  final StaffRepository repository;
  GetStaffListUseCase(this.repository);

  Future<List<Staff>> call(String? hostelId) {
    return repository.getStaff(hostelId);
  }
}

class CreateStaffUseCase {
  final StaffRepository repository;
  CreateStaffUseCase(this.repository);

  Future<void> call({
    required String hostelId,
    required String name,
    required String phone,
    String? email,
    String? password,
    required String role,
    Map<String, dynamic>? permissions,
  }) {
    return repository.createStaff(
      hostelId: hostelId,
      name: name,
      phone: phone,
      email: email,
      password: password,
      role: role,
      permissions: permissions,
    );
  }
}

class UpdateStaffUseCase {
  final StaffRepository repository;
  UpdateStaffUseCase(this.repository);

  Future<void> call(String id, Map<String, dynamic> data) {
    return repository.updateStaff(id, data);
  }
}

class LogStaffActivityUseCase {
  final StaffRepository repository;
  LogStaffActivityUseCase(this.repository);

  Future<void> call(String id, String action, String? details) {
    return repository.logActivity(id, action, details);
  }
}

class GetStaffByIdUseCase {
  final StaffRepository repository;
  GetStaffByIdUseCase(this.repository);

  Future<Staff> call(String id) {
    return repository.getStaffById(id);
  }
}
