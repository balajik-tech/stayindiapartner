import '../../domain/entities/payment_summary.dart';

class PaymentSummaryModel extends PaymentSummary {
  PaymentSummaryModel({
    super.id,
    required super.status,
    required super.amount,
    required super.paymentDate,
    super.paymentReference,
    super.failureReason,
    required super.propertyName,
    required super.totalBeds,
    required super.planName,
    required super.pricePerBedPerMonth,
    required super.durationMonths,
    required super.startDate,
    required super.endDate,
    required super.savedAmount,
    required super.transactionId,
  });

  factory PaymentSummaryModel.fromJson(Map<String, dynamic> json) {
    final property = json['property'] as Map<String, dynamic>;
    final plan = json['plan'] as Map<String, dynamic>;
    final validity = json['validity'] as Map<String, dynamic>;

    return PaymentSummaryModel(
      id: json['_id'] ?? json['id'],
      status: json['status'] ?? '',
      amount: (json['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(json['paymentDate']),
      paymentReference: json['paymentReference'],
      failureReason: json['failureReason'],
      propertyName: property['name'] ?? '',
      totalBeds: property['totalBeds'] ?? 0,
      planName: plan['name'] ?? '',
      pricePerBedPerMonth: (plan['pricePerBedPerMonth'] as num).toDouble(),
      durationMonths: plan['durationMonths'] ?? 0,
      startDate: DateTime.parse(validity['startDate']),
      endDate: DateTime.parse(validity['endDate']),
      savedAmount: (json['savedAmount'] as num).toDouble(),
      transactionId: json['transactionId'] ?? '',
    );
  }
}
