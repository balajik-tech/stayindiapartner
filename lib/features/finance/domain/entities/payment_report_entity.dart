import 'package:equatable/equatable.dart';

class PaymentReportItem extends Equatable {
  final String id;
  final String tenantName;
  final String? roomNo;
  final String? bedNo;
  final String hostelName;
  final double totalPaid;
  final DateTime paymentDate;
  final String? paymentMethod; // stayindia, direct
  final String? status; // settled, settling, etc
  final String? referenceNo;

  const PaymentReportItem({
    required this.id,
    required this.tenantName,
    this.roomNo,
    this.bedNo,
    required this.hostelName,
    required this.totalPaid,
    required this.paymentDate,
    this.paymentMethod,
    this.status,
    this.referenceNo,
  });

  @override
  List<Object?> get props => [
        id,
        tenantName,
        roomNo,
        bedNo,
        hostelName,
        totalPaid,
        paymentDate,
        paymentMethod,
        status,
        referenceNo,
      ];
}
