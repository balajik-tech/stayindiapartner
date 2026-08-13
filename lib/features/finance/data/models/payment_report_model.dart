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

  factory PaymentReportModel.fromTenantRentalJson(Map<String, dynamic> json) {
    final tenant = json['tenant'] ?? {};
    final hostel = json['hostel'] ?? {};
    final booking = json['booking'] ?? {};
    final room = booking['room'] ?? {};
    final payment = json['payment'] ?? {};

    String? status = json['paymentStatus'] ?? payment['status'];
    if (status?.toUpperCase() == 'SUCCESS') {
      status = 'Settled';
    }

    return PaymentReportModel(
      id: json['_id'] ?? '',
      tenantName: '${tenant['firstName'] ?? ''} ${tenant['lastName'] ?? ''}'.trim(),
      roomNo: room['roomTypename'],
      bedNo: booking['bedNumber']?.toString(),
      hostelName: hostel['name'] ?? '',
      totalPaid: (payment['amount'] ?? json['payableAmount'] ?? 0).toDouble(),
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
          : (payment['paidAt'] != null 
              ? DateTime.parse(payment['paidAt'])
              : DateTime.now()),
      paymentMethod: payment['method'],
      status: status,
      referenceNo: payment['reference'],
    );
  }
}
