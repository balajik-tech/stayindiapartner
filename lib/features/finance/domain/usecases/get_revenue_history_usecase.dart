import 'package:stayindia_owner/features/finance/domain/entities/revenue_history_item.dart';
import 'package:stayindia_owner/features/finance/domain/repositories/finance_repository.dart';

class GetRevenueHistoryUseCase {
  final FinanceRepository repository;

  GetRevenueHistoryUseCase({required this.repository});

  Future<List<RevenueHistoryItem>> call({
    String? hostelId,
    String? startDate,
    String? endDate,
    String? type,
  }) {
    return repository.getRevenueHistory(
      hostelId: hostelId,
      startDate: startDate,
      endDate: endDate,
      type: type,
    );
  }
}
