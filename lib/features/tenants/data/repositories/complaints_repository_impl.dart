import 'package:stayindia_owner/features/tenants/domain/entities/complaint.dart';
import 'package:stayindia_owner/features/tenants/domain/repositories/complaints_repository.dart';
import '../datasources/complaints_remote_datasource.dart';

class ComplaintsRepositoryImpl implements ComplaintsRepository {
  final ComplaintsRemoteDataSource remoteDataSource;

  ComplaintsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Complaint>> getComplaints(String hostelId) {
    return remoteDataSource.getComplaints(hostelId);
  }

  @override
  Future<Complaint> getComplaintById(String id) {
    return remoteDataSource.getComplaintById(id);
  }

  @override
  Future<void> updateComplaint(String id, Map<String, dynamic> data) {
    return remoteDataSource.updateComplaint(id, data);
  }
}
