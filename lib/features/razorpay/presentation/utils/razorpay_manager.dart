import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../screens/payment_failed_screen.dart';
import '../screens/payment_success_screen.dart';

class RazorpayManager {
  late Razorpay _razorpay;
  final String apiKey;

  RazorpayManager({required this.apiKey}) {
    _razorpay = Razorpay();
  }

  // Expose the raw Razorpay instance for specialized use cases like Cubits
  Razorpay get instance => _razorpay;

  void openCheckout({
    required BuildContext context,
    required int amount,
    required String name,
    String? description,
    String orderId = "",
    String? email,
    String? contact,
    Function(PaymentSuccessResponse)? onSuccess,
    Function(PaymentFailureResponse)? onFailure,
  }) {
    _razorpay.clear(); // Clear existing listeners to avoid duplicates
    
    // Setup listeners for this specific checkout
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response) {
      logSuccess(response);
      if (onSuccess != null) {
        onSuccess(response);
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PaymentSuccessScreen()),
        );
      }
    });

    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse response) {
      logFailure(response);
      if (onFailure != null) {
        onFailure(response);
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PaymentFailedScreen()),
        );
      }
    });

    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, (ExternalWalletResponse response) {
      debugPrint("EXTERNAL_WALLET: ${response.walletName}");
    });

    final options = {
      'key': apiKey,
      'amount': amount,
      'name': name,
      'description': description ?? '',
      'prefill': {
        'contact': contact,
        'email': email,
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
      debugPrint("Razorpay Exception: $e");
    }
  }

  void logSuccess(PaymentSuccessResponse response) {
    debugPrint('========== Razorpay Success ==========');
    debugPrint('Payment ID : ${response.paymentId}');
    debugPrint('Order ID   : ${response.orderId}');
    debugPrint('Signature  : ${response.signature}');
    debugPrint('Data       : ${response.data}');
    debugPrint('======================================');
  }

  void logFailure(PaymentFailureResponse response) {
    debugPrint('========== Razorpay Failure ==========');
    debugPrint("Razorpay ERROR: ${response.code} - ${response.message}");
    debugPrint('======================================');
  }

  void clear() {
    _razorpay.clear();
  }
}
