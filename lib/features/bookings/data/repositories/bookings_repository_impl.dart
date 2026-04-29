import 'package:stayindia_owner/features/bookings/domain/booking.dart';
import 'package:stayindia_owner/features/bookings/domain/bookings_repository.dart';
import '../datasources/bookings_remote_datasource.dart';

class BookingsRepositoryImpl implements BookingsRepository {
  final BookingsRemoteDataSource remote;

  BookingsRepositoryImpl({required this.remote});

  @override
  Future<List<Booking>> getOwnerBookings({int page = 1, int limit = 10, String? kycStatus, String? roomType}) {
    return remote.getOwnerBookings(page: page, limit: limit, kycStatus: kycStatus, roomType: roomType);
  }

  @override
  Future<List<PendingBooking>> getConfirmedBookings({int page = 1, int limit = 10}) {
    return remote.getConfirmedBookings(page: page, limit: limit);
  }

  @override
  Future<List<PendingBooking>> getPendingBookings({int page = 1, int limit = 10}) {
    return remote.getPendingBookings(page: page, limit: limit);
  }

  @override
  Future<ScanBookingResponse> scanBooking(String token, {String? hostelId}) {
    return remote.scanBooking(token, hostelId: hostelId);
  }

  @override
  Future<ScanBookingResponse> manualCheckin(String accessCode, {String? hostelId}) {
    return remote.manualCheckin(accessCode, hostelId: hostelId);
  }

  @override
  Future<void> assignRoom(String bookingId, String roomId, String bedNumber) {
    return remote.assignRoom(bookingId, roomId, bedNumber);
  }

  @override
  Future<void> confirmBooking(String bookingId, String razorpayOrderId,
      String razorpayPaymentId, String razorpaySignature) {
    return remote.confirmBooking(
        bookingId, razorpayOrderId, razorpayPaymentId, razorpaySignature);
  }

  @override
  Future<Booking> getBookingById(String id) {
    return remote.getBookingById(id);
  }

  @override
  Future<void> checkoutBooking(String bookingId) {
    return remote.checkoutBooking(bookingId);
  }

  @override
  Future<void> cancelBooking(String bookingId) {
    return remote.cancelBooking(bookingId);
  }

  @override
  Future<Map<String, dynamic>> createTransaction({
    required String bookingId,
    required String hostelId,
    required double amount,
    required String paymentMethod,
    required String idempotencyKey,
    String? referenceId,
  }) {
    return remote.createTransaction(
      bookingId: bookingId,
      hostelId: hostelId,
      amount: amount,
      paymentMethod: paymentMethod,
      idempotencyKey: idempotencyKey,
      referenceId: referenceId,
    );
  }

  @override
  Future<ScanBookingResponse> getCheckinData({
    String? bookingId,
    String? accessCode,
    String? hostelId,
  }) {
    return remote.getCheckinData(
      bookingId: bookingId,
      accessCode: accessCode,
      hostelId: hostelId,
    );
  }

  @override
  Future<void> finalizeCheckin({
    required String bookingId,
    required String roomId,
    required String bedNumber,
    String? accessCode,
    List<Map<String, String>>? documents,
  }) {
    return remote.finalizeCheckin(
      bookingId: bookingId,
      roomId: roomId,
      bedNumber: bedNumber,
      accessCode: accessCode,
      documents: documents,
    );
  }
}
