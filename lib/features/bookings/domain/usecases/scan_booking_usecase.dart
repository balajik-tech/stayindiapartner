import '../booking.dart';
import '../bookings_repository.dart';

class ScanBookingUseCase {
  final BookingsRepository repository;

  ScanBookingUseCase({required this.repository});

  Future<ScanBookingResponse> execute(String identifier, {String? hostelId, bool isManual = false}) {
    if (isManual) {
      return repository.manualCheckin(identifier, hostelId: hostelId);
    }
    return repository.scanBooking(identifier, hostelId: hostelId);
  }
}
