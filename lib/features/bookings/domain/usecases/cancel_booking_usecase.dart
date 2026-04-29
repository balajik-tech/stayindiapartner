import '../bookings_repository.dart';

class CancelBookingUseCase {
  final BookingsRepository repository;

  CancelBookingUseCase({required this.repository});

  Future<void> execute(String bookingId) {
    return repository.cancelBooking(bookingId);
  }
}
