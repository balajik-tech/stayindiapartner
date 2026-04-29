import '../bookings_repository.dart';

class CheckoutBookingUseCase {
  final BookingsRepository repository;

  CheckoutBookingUseCase({required this.repository});

  Future<void> execute(String bookingId) {
    return repository.checkoutBooking(bookingId);
  }
}
