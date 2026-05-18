import 'booking.dart';

abstract class BookingsRepository {
  Future<List<Booking>> getOwnerBookings({
    int page = 1,
    int limit = 10,
    String? kycStatus,
    String? roomType,
    String? hostelId,
  });
  Future<List<PendingBooking>> getPendingBookings({
    int page = 1,
    int limit = 10,
  });
  Future<List<PendingBooking>> getConfirmedBookings({
    int page = 1,
    int limit = 10,
  });
  Future<ScanBookingResponse> scanBooking(
    String token, {
    String? hostelId,
    String? bookingId,
  });
  Future<ScanBookingResponse> manualCheckin(
    String accessCode, {
    String? hostelId,
    String? bookingId,
  });
  Future<ScanBookingResponse> getCheckinData({
    String? bookingId,
    String? accessCode,
    String? hostelId,
  });
  Future<void> assignRoom(String bookingId, String roomId, String bedNumber);
  Future<void> finalizeCheckin({
    required String bookingId,
    required String roomId,
    required String bedNumber,
    String? accessCode,
    List<Map<String, String>>? documents,
  });
  Future<Map<String, dynamic>> createTransaction({
    required String bookingId,
    required String hostelId,
    required double amount,
    required String paymentMethod,
    required String idempotencyKey,
    String? referenceId,
  });
  Future<void> confirmBooking(
    String bookingId,
    String razorpayOrderId,
    String razorpayPaymentId,
    String razorpaySignature,
  );
  Future<Booking> getBookingById(String id);
  Future<void> checkoutBooking(String bookingId);
  Future<void> cancelBooking(String bookingId);
}
