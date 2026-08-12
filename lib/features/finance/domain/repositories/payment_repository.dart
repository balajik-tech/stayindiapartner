import '../entities/payment_report_entity.dart';

abstract class PaymentRepository {
  Future<List<PaymentReportItem>> getPaymentReport({
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
}
