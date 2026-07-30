class PaymentSummary {
  final String? id;
  final String status;
  final double amount;
  final DateTime paymentDate;
  final String? paymentReference;
  final String? failureReason;
  final String propertyName;
  final int totalBeds;
  final String planName;
  final double pricePerBedPerMonth;
  final int durationMonths;
  final DateTime startDate;
  final DateTime endDate;
  final double savedAmount;
  final String transactionId;

  PaymentSummary({
    this.id,
    required this.status,
    required this.amount,
    required this.paymentDate,
    this.paymentReference,
    this.failureReason,
    required this.propertyName,
    required this.totalBeds,
    required this.planName,
    required this.pricePerBedPerMonth,
    required this.durationMonths,
    required this.startDate,
    required this.endDate,
    required this.savedAmount,
    required this.transactionId,
  });

  PaymentSummary copyWith({
    String? id,
    String? status,
    double? amount,
    DateTime? paymentDate,
    String? paymentReference,
    String? failureReason,
    String? propertyName,
    int? totalBeds,
    String? planName,
    double? pricePerBedPerMonth,
    int? durationMonths,
    DateTime? startDate,
    DateTime? endDate,
    double? savedAmount,
    String? transactionId,
  }) {
    return PaymentSummary(
      id: id ?? this.id,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      paymentReference: paymentReference ?? this.paymentReference,
      failureReason: failureReason ?? this.failureReason,
      propertyName: propertyName ?? this.propertyName,
      totalBeds: totalBeds ?? this.totalBeds,
      planName: planName ?? this.planName,
      pricePerBedPerMonth: pricePerBedPerMonth ?? this.pricePerBedPerMonth,
      durationMonths: durationMonths ?? this.durationMonths,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      savedAmount: savedAmount ?? this.savedAmount,
      transactionId: transactionId ?? this.transactionId,
    );
  }
}
