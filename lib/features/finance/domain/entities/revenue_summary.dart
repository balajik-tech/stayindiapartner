import 'package:equatable/equatable.dart';

class RevenueSummary extends Equatable {
  final double totalCollected;
  final int paymentCount;
  final int tenantCount;
  final double viaStayIndia;
  final double direct;
  final double settlingAmount;
  final String period;
  
  // New fields from API
  final double? totalUpi;
  final double? totalCash;
  final int? razorpayCount;
  final int? upiCount;
  final int? cashCount;

  const RevenueSummary({
    required this.totalCollected,
    required this.paymentCount,
    required this.tenantCount,
    required this.viaStayIndia,
    required this.direct,
    required this.settlingAmount,
    required this.period,
    this.totalUpi,
    this.totalCash,
    this.razorpayCount,
    this.upiCount,
    this.cashCount,
  });

  @override
  List<Object?> get props => [
        totalCollected,
        paymentCount,
        tenantCount,
        viaStayIndia,
        direct,
        settlingAmount,
        period,
        totalUpi,
        totalCash,
        razorpayCount,
        upiCount,
        cashCount,
      ];
}
