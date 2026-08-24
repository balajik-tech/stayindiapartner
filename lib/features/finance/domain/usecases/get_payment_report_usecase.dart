import '../../../../core/constants/api_constants.dart';
import '../entities/payment_report_entity.dart';
import '../repositories/payment_repository.dart';

class GetPaymentReportUseCase {
  final PaymentRepository repository;

  GetPaymentReportUseCase({required this.repository});

  Future<PaymentReportData> call({
    String? hostelId,
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = ApiConstants.paginationLimit,
  }) {
    return repository.getPaymentReport(
      hostelId: hostelId,
      startDate: startDate,
      endDate: endDate,
      page: page,
      limit: limit,
    );
  }
}
