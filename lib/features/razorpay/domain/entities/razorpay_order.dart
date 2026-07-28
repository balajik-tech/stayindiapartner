class RazorpayOrder {
  final String id;
  final int amount;
  final String currency;
  final String? description;

  RazorpayOrder({
    required this.id,
    required this.amount,
    required this.currency,
    this.description,
  });
}
