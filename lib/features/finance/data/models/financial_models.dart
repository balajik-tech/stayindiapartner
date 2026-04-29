import '../../domain/entities/financial_entities.dart';

class FinancialStatsModel extends FinancialStats {
  const FinancialStatsModel({
    required super.totalRevenue,
    required super.thisMonthRevenue,
    required super.occupancyRate,
    required super.totalBeds,
    required super.occupiedBeds,
    required super.pendingPayments,
  });

  factory FinancialStatsModel.fromJson(Map<String, dynamic> json) {
    return FinancialStatsModel(
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      thisMonthRevenue: (json['thisMonthRevenue'] ?? 0).toDouble(),
      occupancyRate: (json['occupancyRate'] ?? 0).toDouble(),
      totalBeds: (json['totalBeds'] ?? 0).toInt(),
      occupiedBeds: (json['occupiedBeds'] ?? 0).toInt(),
      pendingPayments: (json['pendingPayments'] ?? 0).toDouble(),
    );
  }
}

class RevenueTrendModel extends RevenueTrend {
  const RevenueTrendModel({
    required super.date,
    required super.revenue,
    required super.count,
  });

  factory RevenueTrendModel.fromJson(Map<String, dynamic> json) {
    return RevenueTrendModel(
      date: json['date'] ?? '',
      revenue: (json['revenue'] ?? 0).toDouble(),
      count: (json['count'] ?? 0).toInt(),
    );
  }
}
