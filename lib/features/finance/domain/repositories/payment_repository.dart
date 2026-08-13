import '../entities/payment_report_entity.dart';

abstract class PaymentRepository {
  Future<PaymentReportData> getPaymentReport({
    String? hostelId,
    String? startDate,
    String? endDate,
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
    required String dueDate,
    String? notes,
  });

  Future<String> createUpiOrder({
    required String tenantId,
    required String hostelId,
    required String bookingId,
    required double amount,
    required String dueDate,
    String? notes,
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
