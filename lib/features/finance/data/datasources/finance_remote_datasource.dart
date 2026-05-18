import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/financial_models.dart';
import '../models/revenue_history_item_model.dart';

abstract class FinanceRemoteDataSource {
  Future<FinancialStatsModel> getFinancialStats({String? hostelId});
  Future<List<RevenueTrendModel>> getRevenueAnalytics({
    String? hostelId,
    String? startDate,
    String? endDate,
    String? interval,
  });
  Future<List<RevenueHistoryItemModel>> getRevenueHistory({
    String? hostelId,
    String? startDate,
    String? endDate,
    String? type,
  });
}

class FinanceRemoteDataSourceImpl implements FinanceRemoteDataSource {
  final Dio dio;

  FinanceRemoteDataSourceImpl({required this.dio});

  @override
  Future<FinancialStatsModel> getFinancialStats({String? hostelId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (hostelId != null) queryParams['hostelId'] = hostelId;

      final response = await dio.get(
        ApiConstants.financeStats,
        queryParameters: queryParams,
      );
      return FinancialStatsModel.fromJson(response.data['data']);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<RevenueTrendModel>> getRevenueAnalytics({
    String? hostelId,
    String? startDate,
    String? endDate,
    String? interval,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (hostelId != null) queryParams['hostelId'] = hostelId;
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;
      if (interval != null) queryParams['interval'] = interval;

      final response = await dio.get(
        ApiConstants.financeAnalytics,
        queryParameters: queryParams,
      );
      final List results = response.data['data']['revenueTrends'] ?? [];
      return results.map((e) => RevenueTrendModel.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<RevenueHistoryItemModel>> getRevenueHistory({
    String? hostelId,
    String? startDate,
    String? endDate,
    String? type,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (hostelId != null) queryParams['hostelId'] = hostelId;
      if (startDate != null) queryParams['startDate'] = startDate;
      if (endDate != null) queryParams['endDate'] = endDate;
      if (type != null) queryParams['type'] = type;

      final response = await dio.get(
        ApiConstants.financeRevenueHistory,
        queryParameters: queryParams,
      );
      final List results = response.data['data'] ?? [];
      return results.map((e) => RevenueHistoryItemModel.fromJson(e)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
