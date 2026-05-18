import '../../domain/entities/guest_request.dart';
import '../../domain/repositories/guest_repository.dart';
import '../datasource/guest_remote_datasource.dart';

class GuestRepositoryImpl implements GuestRepository {
  final GuestRemoteDataSource remoteDataSource;

  GuestRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<GuestRequest>> getHostelGuestRequests(String hostelId) async {
    return await remoteDataSource.getHostelGuestRequests(hostelId);
  }

  @override
  Future<GuestRequest> updateGuestRequestStatus(
    String requestId,
    String status, {
    String? rejectionReason,
  }) async {
    return await remoteDataSource.updateGuestRequestStatus(
      requestId,
      status,
      rejectionReason: rejectionReason,
    );
  }
}
