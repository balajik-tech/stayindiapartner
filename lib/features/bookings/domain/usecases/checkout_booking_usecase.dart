import '../bookings_repository.dart';
import 'package:stayindia_owner/features/bookings/domain/settlement_payment.dart';

class CheckoutBookingUseCase {
  final BookingsRepository repository;

  CheckoutBookingUseCase({required this.repository});

  Future<void> execute(
    String bookingId, {
    double? securityDeposit,
    double? pendingRent,
    double? utilityDue,
    double? finalSettlement,
    List<SettlementPayment> settlementPayments = const [],
  }) {
    return repository.checkoutBooking(
      bookingId,
      securityDeposit: securityDeposit,
      pendingRent: pendingRent,
      utilityDue: utilityDue,
      finalSettlement: finalSettlement,
      settlementPayments: settlementPayments,
    );
  }
}
