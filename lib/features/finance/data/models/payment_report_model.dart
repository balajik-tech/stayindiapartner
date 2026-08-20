import 'package:intl/intl.dart';
import '../../domain/entities/payment_report_entity.dart';
import '../../domain/entities/revenue_summary.dart';

class PaymentReportModel extends PaymentReportItem {
  const PaymentReportModel({
    required super.id,
    required super.tenantName,
    super.roomNo,
    super.bedNo,
    required super.hostelId,
    required super.hostelName,
    required super.totalPaid,
    required super.paymentDate,
    super.paymentMethod,
    super.status,
    super.referenceNo,
    super.bankName,
  });

  factory PaymentReportModel.fromJson(Map<String, dynamic> json) {
    return PaymentReportModel(
      id: json['id'] ?? json['_id'] ?? '',
      tenantName: json['tenantName'] ?? '',
      roomNo: json['roomNo'],
      bedNo: json['bedNo'],
      hostelId: json['hostelId'] ?? '',
      hostelName: json['hostelName'] ?? '',
      totalPaid: (json['totalPaid'] ?? 0).toDouble(),
      paymentDate: json['paymentDate'] != null
          ? DateTime.parse(json['paymentDate'])
          : DateTime.now(),
      paymentMethod: json['paymentMethod'],
      status: json['status'],
      referenceNo: json['referenceNo'],
      bankName: json['bankName'],
    );
  }

  factory PaymentReportModel.fromTenantRentalJson(Map<String, dynamic> json) {
    final tenant = json['tenant'] ?? {};
    final hostel = json['hostel'] ?? {};
    final booking = json['booking'] ?? {};
    final room = booking['room'] ?? {};
    final payment = json['payment'] ?? {};
    final razorpay = json['razorpay'] ?? {};
    final paymentResponse = razorpay['paymentResponse'] ?? {};

    String? status = json['paymentStatus'] ?? payment['status'];
    if (status?.toUpperCase() == 'SUCCESS') {
      status = 'Settled';
    }

    double totalPaid = (payment['amount'] ?? 0).toDouble();
    if (totalPaid == 0) {
      totalPaid = (json['payableAmount'] ?? 0).toDouble();
    }

    DateTime paymentDate;
    if (json['paymentDate'] != null) {
      paymentDate = DateTime.parse(json['paymentDate']);
    } else if (payment['paidAt'] != null) {
      paymentDate = DateTime.parse(payment['paidAt']);
    } else if (json['createdAt'] != null) {
      paymentDate = DateTime.parse(json['createdAt']);
    } else {
      paymentDate = DateTime.now();
    }

    String? reference = payment['reference'];
    if ((reference == null || reference.isEmpty) &&
        razorpay['paymentId'] != null &&
        razorpay['paymentId'].toString().isNotEmpty) {
      reference = razorpay['paymentId'];
    }

    return PaymentReportModel(
      id: json['_id'] ?? '',
      tenantName:
          '${tenant['firstName'] ?? ''} ${tenant['lastName'] ?? ''}'.trim(),
      roomNo: room['roomTypename'],
      bedNo: booking['bedNumber']?.toString(),
      hostelId: hostel['_id'] ?? hostel['id'] ?? '',
      hostelName: hostel['name'] ?? '',
      totalPaid: totalPaid,
      paymentDate: paymentDate,
      paymentMethod: payment['method'],
      status: status,
      referenceNo: reference,
      bankName: paymentResponse['bank'],
    );
  }

  static RevenueSummary summaryFromJson(Map<String, dynamic> json, int tenantCount) {
    return RevenueSummary(
      totalCollected: (json['totalAmount'] ?? 0).toDouble(),
      paymentCount: json['totalPayments'] ?? 0,
      tenantCount: tenantCount,
      viaStayIndia: (json['totalRazorpay'] ?? 0).toDouble(),
      direct: ((json['totalUpi'] ?? 0) + (json['totalCash'] ?? 0)).toDouble(),
      settlingAmount: 0, // Not provided in new summary
      period: DateFormat('MMMM').format(DateTime.now()),
      totalUpi: (json['totalUpi'] ?? 0).toDouble(),
      totalCash: (json['totalCash'] ?? 0).toDouble(),
      razorpayCount: json['razorpayCount'],
      upiCount: json['upiCount'],
      cashCount: json['cashCount'],
    );
  }
}
