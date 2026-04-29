import 'package:stayindia_owner/features/tenants/domain/entities/complaint.dart';
import 'package:stayindia_owner/features/tenants/domain/repositories/complaints_repository.dart';

class GetComplaintsUseCase {
  final ComplaintsRepository repository;
  GetComplaintsUseCase(this.repository);

  Future<List<Complaint>> call(String hostelId) {
    return repository.getComplaints(hostelId);
  }
}

class UpdateComplaintStatusUseCase {
  final ComplaintsRepository repository;
  UpdateComplaintStatusUseCase(this.repository);

  Future<void> call(String complaintId, String status) {
    return repository.updateComplaint(complaintId, {'status': status});
  }
}
