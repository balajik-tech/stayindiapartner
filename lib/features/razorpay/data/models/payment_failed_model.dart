class PaymentFailedDetail {
  final String label;
  final String value;

  const PaymentFailedDetail({required this.label, required this.value});
}

class PaymentFailedActions {
  final String primary;
  final String secondary;
  final String tertiary;

  const PaymentFailedActions({
    required this.primary,
    required this.secondary,
    required this.tertiary,
  });
}

class PaymentFailedModel {
  final String status;
  final String title;
  final String message;
  final num amount;
  final String currencySymbol;
  final String attemptedOn;
  final String reason;
  final List<PaymentFailedDetail> details;
  final PaymentFailedActions actions;

  const PaymentFailedModel({
    required this.status,
    required this.title,
    required this.message,
    required this.amount,
    required this.currencySymbol,
    required this.attemptedOn,
    required this.reason,
    required this.details,
    required this.actions,
  });

  /// Formats amount with Indian-style comma grouping, e.g. 29736 -> "₹29,736"
  String get formattedAmount {
    final String raw = amount.toStringAsFixed(0);
    if (raw.length <= 3) return '$currencySymbol$raw';

    final String lastThree = raw.substring(raw.length - 3);
    String remaining = raw.substring(0, raw.length - 3);
    final RegExp pattern = RegExp(r'(\d)(?=(\d\d)+(?!\d))');
    remaining = remaining.replaceAllMapped(pattern, (m) => '${m[1]},');
    return '$currencySymbol$remaining,$lastThree';
  }
}
