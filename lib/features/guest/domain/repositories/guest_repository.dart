import '../entities/guest_request.dart';

abstract class GuestRepository {
  Future<List<GuestRequest>> getHostelGuestRequests(String hostelId);
  Future<GuestRequest> updateGuestRequestStatus(String requestId, String status, {String? rejectionReason});
}
