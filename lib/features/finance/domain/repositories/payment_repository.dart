import '../../../../core/constants/api_constants.dart';
import '../entities/payment_report_entity.dart';

abstract class PaymentRepository {
  Future<PaymentReportData> getPaymentReport({
    String? hostelId,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = ApiConstants.paginationLimit,
  });

  Future<void> recordPayment({
    required String tenantId,
    required double amount,
    required String category,
    required String mode,
    required String date,
    String? referenceNo,
    String? note,
    String? screenshotPath,
    bool sendWhatsapp = true,
  });

  Future<String> createCashOrder({
    required String tenantId,
    required String hostelId,
    required String bookingId,
    required double amount,
    double rent = 0,
    double deposit = 0,
    double utilities = 0,
    double others = 0,
    required String dueDate,
    String? notes,
    String? startDate,
    String? endDate,
    String? forthePeriod,
  });

  Future<String> createUpiOrder({
    required String tenantId,
    required String hostelId,
    required String bookingId,
    required double amount,
    double rent = 0,
    double deposit = 0,
    double utilities = 0,
    double others = 0,
    required String dueDate,
    String? notes,
    String? startDate,
    String? endDate,
    String? forthePeriod,
  });

  Future<void> recordCashPayment({
    required String rentalId,
    required double amount,
    required String reference,
    String? notes,
  });

  Future<void> recordUpiPayment({
    required String rentalId,
    required double amount,
    required String reference,
    String? notes,
  });
}
