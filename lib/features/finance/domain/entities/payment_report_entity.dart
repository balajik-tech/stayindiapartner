import 'package:equatable/equatable.dart';
import 'revenue_summary.dart';

class PaymentReportItem extends Equatable {
  final String id;
  final String tenantName;
  final String? roomNo;
  final String? bedNo;
  final String hostelId;
  final String hostelName;
  final double totalPaid;
  final DateTime paymentDate;
  final String? paymentMethod; // stayindia, direct
  final String? status; // settled, settling, etc
  final String? referenceNo;
  final String? bankName;

  const PaymentReportItem({
    required this.id,
    required this.tenantName,
    this.roomNo,
    this.bedNo,
    required this.hostelId,
    required this.hostelName,
    required this.totalPaid,
    required this.paymentDate,
    this.paymentMethod,
    this.status,
    this.referenceNo,
    this.bankName,
  });

  @override
  List<Object?> get props => [
        id,
        tenantName,
        roomNo,
        bedNo,
        hostelId,
        hostelName,
        totalPaid,
        paymentDate,
        paymentMethod,
        status,
        referenceNo,
        bankName,
      ];
}

class PaymentReportData extends Equatable {
  final List<PaymentReportItem> payments;
  final RevenueSummary summary;

  const PaymentReportData({
    required this.payments,
    required this.summary,
  });

  @override
  List<Object?> get props => [payments, summary];
}
