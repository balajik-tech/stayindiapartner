import '../../domain/entities/financial_entities.dart';
import '../../domain/entities/revenue_history_item.dart';
import '../../domain/repositories/finance_repository.dart';
import '../datasources/finance_remote_datasource.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  final FinanceRemoteDataSource remoteDataSource;

  FinanceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<FinancialStats> getFinancialStats({String? hostelId}) {
    return remoteDataSource.getFinancialStats(hostelId: hostelId);
  }

  @override
  Future<List<RevenueTrend>> getRevenueAnalytics({
    String? hostelId,
    String? startDate,
    String? endDate,
    String? interval,
  }) {
    return remoteDataSource.getRevenueAnalytics(
      hostelId: hostelId,
      startDate: startDate,
      endDate: endDate,
      interval: interval,
    );
  }

  @override
  Future<List<RevenueHistoryItem>> getRevenueHistory({
    String? hostelId,
    String? startDate,
    String? endDate,
    String? type,
  }) {
    return remoteDataSource.getRevenueHistory(
      hostelId: hostelId,
      startDate: startDate,
      endDate: endDate,
      type: type,
    );
  }
}
