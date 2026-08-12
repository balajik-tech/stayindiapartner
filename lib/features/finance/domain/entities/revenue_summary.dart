import 'package:equatable/equatable.dart';

class RevenueSummary extends Equatable {
  final double totalCollected;
  final int paymentCount;
  final int tenantCount;
  final double viaStayIndia;
  final double direct;
  final double settlingAmount;
  final String period;

  const RevenueSummary({
    required this.totalCollected,
    required this.paymentCount,
    required this.tenantCount,
    required this.viaStayIndia,
    required this.direct,
    required this.settlingAmount,
    required this.period,
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
      ];
}
