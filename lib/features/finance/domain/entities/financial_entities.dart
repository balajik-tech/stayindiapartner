import 'package:equatable/equatable.dart';

class FinancialStats extends Equatable {
  final double totalRevenue;
  final double thisMonthRevenue;
  final double occupancyRate;
  final int totalBeds;
  final int occupiedBeds;
  final double pendingPayments;
  final double securityDeposit;
  final double maintenance;
  final double dailyRent;

  const FinancialStats({
    required this.totalRevenue,
    required this.thisMonthRevenue,
    required this.occupancyRate,
    required this.totalBeds,
    required this.occupiedBeds,
    required this.pendingPayments,
    required this.securityDeposit,
    required this.maintenance,
    required this.dailyRent,
  });

  @override
  List<Object?> get props => [
    totalRevenue,
    thisMonthRevenue,
    occupancyRate,
    totalBeds,
    occupiedBeds,
    pendingPayments,
    securityDeposit,
    maintenance,
    dailyRent,
  ];
}

class RevenueTrend extends Equatable {
  final String date;
  final double revenue;
  final int count;

  const RevenueTrend({
    required this.date,
    required this.revenue,
    required this.count,
  });

  @override
  List<Object?> get props => [date, revenue, count];
}
