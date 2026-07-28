class RazorpayPaymentResult {
  final String? paymentId;
  final String? orderId;
  final String? signature;
  final String? errorCode;
  final String? errorMessage;
  final bool isSuccess;

  RazorpayPaymentResult.success({
    required this.paymentId,
    required this.orderId,
    required this.signature,
  })  : isSuccess = true,
        errorCode = null,
        errorMessage = null;

  RazorpayPaymentResult.error({
    required this.errorCode,
    required this.errorMessage,
  })  : isSuccess = false,
        paymentId = null,
        orderId = null,
        signature = null;
}
