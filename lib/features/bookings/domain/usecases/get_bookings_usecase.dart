import '../booking.dart';
import '../bookings_repository.dart';

class GetBookingsUseCase {
  final BookingsRepository repository;

  GetBookingsUseCase({required this.repository});

  Future<List<Booking>> execute({int page = 1, int limit = 10, String? kycStatus, String? roomType}) {
    return repository.getOwnerBookings(page: page, limit: limit, kycStatus: kycStatus, roomType: roomType);
  }
}
