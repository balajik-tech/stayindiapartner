import '../entities/financial_entities.dart';
import '../entities/revenue_history_item.dart';

abstract class FinanceRepository {
  Future<FinancialStats> getFinancialStats({String? hostelId});
  Future<List<RevenueTrend>> getRevenueAnalytics({
    String? hostelId,
    String? startDate,
    String? endDate,
    String? interval,
  });
  Future<List<RevenueHistoryItem>> getRevenueHistory({
    String? hostelId,
    String? startDate,
    String? endDate,
    String? type,
  });
}
