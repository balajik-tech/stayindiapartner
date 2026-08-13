import '../entities/payment_report_entity.dart';
import '../repositories/payment_repository.dart';

class GetPaymentReportUseCase {
  final PaymentRepository repository;

  GetPaymentReportUseCase({required this.repository});

  Future<PaymentReportData> call({
    String? hostelId,
    String? startDate,
    String? endDate,
  }) {
    return repository.getPaymentReport(
      hostelId: hostelId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
