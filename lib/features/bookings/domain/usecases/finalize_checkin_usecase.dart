import '../bookings_repository.dart';

class FinalizeCheckinUseCase {
  final BookingsRepository repository;

  FinalizeCheckinUseCase({required this.repository});

  Future<void> execute({
    required String bookingId,
    required String roomId,
    required String bedNumber,
    String? accessCode,
    List<Map<String, String>>? documents,
  }) {
    return repository.finalizeCheckin(
      bookingId: bookingId,
      roomId: roomId,
      bedNumber: bedNumber,
      accessCode: accessCode,
      documents: documents,
    );
  }
}
