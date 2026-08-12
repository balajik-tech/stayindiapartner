import '../../domain/entities/payment_report_entity.dart';

class PaymentReportModel extends PaymentReportItem {
  const PaymentReportModel({
    required super.id,
    required super.tenantName,
    super.roomNo,
    super.bedNo,
    required super.hostelName,
    required super.totalPaid,
    required super.paymentDate,
    super.paymentMethod,
    super.status,
    super.referenceNo,
  });

  factory PaymentReportModel.fromJson(Map<String, dynamic> json) {
    return PaymentReportModel(
      id: json['id'] ?? json['_id'] ?? '',
      tenantName: json['tenantName'] ?? '',
      roomNo: json['roomNo'],
      bedNo: json['bedNo'],
      hostelName: json['hostelName'] ?? '',
      totalPaid: (json['totalPaid'] ?? 0).toDouble(),
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
          : DateTime.now(),
      paymentMethod: json['paymentMethod'],
      status: json['status'],
      referenceNo: json['referenceNo'],
    );
  }
}
