import '../entities/financial_entities.dart';
import '../repositories/finance_repository.dart';

class GetFinancialStatsUseCase {
  final FinanceRepository repository;
  GetFinancialStatsUseCase(this.repository);

  Future<FinancialStats> call({String? hostelId}) {
    return repository.getFinancialStats(hostelId: hostelId);
  }
}

class GetRevenueAnalyticsUseCase {
  final FinanceRepository repository;
  GetRevenueAnalyticsUseCase(this.repository);

  Future<List<RevenueTrend>> call({
    String? hostelId,
    String? startDate,
    String? endDate,
    String? interval,
  }) {
    return repository.getRevenueAnalytics(
      hostelId: hostelId,
      startDate: startDate,
      endDate: endDate,
      interval: interval,
    );
  }
}
