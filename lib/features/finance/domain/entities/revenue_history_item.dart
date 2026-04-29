import 'package:equatable/equatable.dart';

class RevenueHistoryItem extends Equatable {
  final String id;
  final String tenantName;
  final String hostelName;
  final double rent;
  final double maintenance;
  final double deposit;
  final double total;
  final double totalPaid;
  final DateTime paymentDate;
  final String month;
  final String? paymentType;

  const RevenueHistoryItem({
    required this.id,
    required this.tenantName,
    required this.hostelName,
    required this.rent,
    required this.maintenance,
    required this.deposit,
    required this.total,
    required this.totalPaid,
    required this.paymentDate,
    required this.month,
    this.paymentType,
  });

  @override
  List<Object?> get props => [
        id,
        tenantName,
        hostelName,
        rent,
        maintenance,
        deposit,
        total,
        totalPaid,
        paymentDate,
        month,
        paymentType,
      ];
}
