import '../bookings_repository.dart';

class CheckoutBookingUseCase {
  final BookingsRepository repository;

  CheckoutBookingUseCase({required this.repository});

  Future<void> execute(
    String bookingId, {
    double? securityDeposit,
    double? pendingRent,
    double? utilityDue,
    double? finalSettlement,
  }) {
    return repository.checkoutBooking(
      bookingId,
      securityDeposit: securityDeposit,
      pendingRent: pendingRent,
      utilityDue: utilityDue,
      finalSettlement: finalSettlement,
    );
  }
}
