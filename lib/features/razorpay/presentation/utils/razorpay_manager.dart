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
    // Setup listeners for this specific checkout
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, (PaymentSuccessResponse response) {
      debugPrint("Razorpay SUCCESS: ${response.paymentId}");
      if (onSuccess != null) {
        onSuccess(response);
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PaymentSuccessScreen()),
        );
      }
      _clearListeners();
    });

    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, (PaymentFailureResponse response) {
      debugPrint("Razorpay ERROR: ${response.code} - ${response.message}");
      if (onFailure != null) {
        onFailure(response);
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PaymentFailedScreen()),
        );
      }
      _clearListeners();
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
      debugPrint("Razorpay Exception: $e");
    }
  }

  void _clearListeners() {
    _razorpay.clear();
  }
}
