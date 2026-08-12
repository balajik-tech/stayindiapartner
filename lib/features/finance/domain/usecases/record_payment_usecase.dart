import '../repositories/payment_repository.dart';

class RecordPaymentUseCase {
  final PaymentRepository repository;

  RecordPaymentUseCase({required this.repository});

  Future<void> call({
    required String tenantId,
    required double amount,
    required String category,
    required String mode,
    required String date,
    String? referenceNo,
    String? note,
    String? screenshotPath,
    bool sendWhatsapp = true,
  }) {
    return repository.recordPayment(
      tenantId: tenantId,
      amount: amount,
      category: category,
      mode: mode,
      date: date,
      referenceNo: referenceNo,
      note: note,
      screenshotPath: screenshotPath,
      sendWhatsapp: sendWhatsapp,
    );
  }
}
