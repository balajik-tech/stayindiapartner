import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../domain/entities/razorpay_payment_result.dart';
import '../screens/payment_failed_screen.dart';
import '../screens/payment_success_screen.dart';

class RazorpayService {
  late Razorpay _razorpay;
  final BuildContext context;
  final String apiKey;

  RazorpayService({
    required this.context,
    required this.apiKey,
  }) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void openCheckout({
    required int amount,
    required String name,
    String? description,
    String orderId = "",
    String? email,
    String? contact,
  }) {
    final options = {
      'key': apiKey,
      'amount': amount,
      'name': name,
      'description': description ?? '',
      'prefill': {
        if (contact != null) 'contact': contact,
        if (email != null) 'email': email,
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    if (orderId.isNotEmpty && !orderId.startsWith("order_test_")) {
      options['order_id'] = orderId;
    }

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint("Razorpay Error: $e");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint("Payment Success: ${response.paymentId}");
    
    // Clear Razorpay listeners before navigating
    _razorpay.clear();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PaymentSuccessScreen(),
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint("Payment Error: ${response.code} - ${response.message}");
    
    _razorpay.clear();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PaymentFailedScreen(),
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("External Wallet: ${response.walletName}");
  }

  void dispose() {
    _razorpay.clear();
  }
}
