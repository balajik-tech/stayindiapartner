class PaymentSummary {
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
}
