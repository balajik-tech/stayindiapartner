class PaymentSuccessDetail {
  final String label;
  final String value;

  /// When true the label/value are rendered in the "success green"
  /// accent color instead of the default text colors (used for the
  /// "You saved" row).
  final bool highlight;

  const PaymentSuccessDetail({
    required this.label,
    required this.value,
    this.highlight = false,
  });
}

class PaymentSuccessActions {
  final String primary;
  final String secondary;

  const PaymentSuccessActions({
    required this.primary,
    required this.secondary,
  });
}

class PaymentSuccessModel {
  final String status;
  final String title;
  final String message;
  final num amount;
  final String currencySymbol;
  final String paidOn;
  final List<PaymentSuccessDetail> details;
  final PaymentSuccessActions actions;

  const PaymentSuccessModel({
    required this.status,
    required this.title,
    required this.message,
    required this.amount,
    required this.currencySymbol,
    required this.paidOn,
    required this.details,
    required this.actions,
  });

  /// Formats amount with Indian-style comma grouping, e.g. 29736 -> "₹29,736"
  String get formattedAmount => _formatAmount(amount, currencySymbol);
}

/// Shared helper so any "₹" value (amount, saved amount, etc.) can use
/// the same Indian-style comma grouping.
String _formatAmount(num amount, String currencySymbol) {
  final String raw = amount.toStringAsFixed(0);
  if (raw.length <= 3) return '$currencySymbol$raw';

  final String lastThree = raw.substring(raw.length - 3);
  String remaining = raw.substring(0, raw.length - 3);
  final RegExp pattern = RegExp(r'(\d)(?=(\d\d)+(?!\d))');
  remaining = remaining.replaceAllMapped(pattern, (m) => '${m[1]},');
  return '$currencySymbol$remaining,$lastThree';
}
