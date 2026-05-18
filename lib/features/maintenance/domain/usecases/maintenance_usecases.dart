import 'package:stayindia_owner/features/maintenance/domain/entities/maintenance.dart';
import 'package:stayindia_owner/features/maintenance/domain/repositories/maintenance_repository.dart';

class GetMaintenanceIssuesUseCase {
  final MaintenanceRepository repository;
  GetMaintenanceIssuesUseCase(this.repository);

  Future<TicketSummary> call({
    String? hostelId,
    String? status,
    String? search,
  }) {
    return repository.getIssues(
      hostelId: hostelId,
      status: status,
      search: search,
    );
  }
}

class CreateMaintenanceIssueUseCase {
  final MaintenanceRepository repository;
  CreateMaintenanceIssueUseCase(this.repository);

  Future<void> call({
    required String hostelId,
    required String title,
    String? description,
    String? roomId,
    String? bedNumber,
    String? status,
  }) {
    return repository.createIssue(
      hostelId: hostelId,
      title: title,
      description: description,
      roomId: roomId,
      bedNumber: bedNumber,
      status: status,
    );
  }
}

class UpdateMaintenanceIssueUseCase {
  final MaintenanceRepository repository;
  UpdateMaintenanceIssueUseCase(this.repository);

  Future<void> call(String id, Map<String, dynamic> data) {
    return repository.updateIssue(id, data);
  }
}

class GetMaintenanceIssueByIdUseCase {
  final MaintenanceRepository repository;
  GetMaintenanceIssueByIdUseCase(this.repository);

  Future<Maintenance> call(String id) {
    return repository.getIssueById(id);
  }
}
