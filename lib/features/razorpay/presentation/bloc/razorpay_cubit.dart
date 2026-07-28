import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../domain/entities/razorpay_payment_result.dart';
import 'razorpay_state.dart';

class RazorpayCubit extends Cubit<RazorpayState> {
  late Razorpay _razorpay;

  RazorpayCubit() : super(RazorpayInitial()) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void openCheckout({
    required String apiKey,
    required int amount,
    required String name,
    String? description,
    required String orderId,
    String? email,
    String? contact,
  }) {
    emit(RazorpayOpeningCheckout());

    final options = {
      'key': apiKey,
      'amount': amount,
      'name': name,
      'description': description ?? '',
      'order_id': orderId,
      'prefill': {
        if (contact != null) 'contact': contact,
        if (email != null) 'email': email,
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      emit(RazorpayFailure("Could not open Razorpay checkout: ${e.toString()}"));
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    emit(RazorpaySuccess(
      RazorpayPaymentResult.success(
        paymentId: response.paymentId,
        orderId: response.orderId,
        signature: response.signature,
      ),
    ));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    emit(RazorpayFailure(
      response.message ?? 'Payment Failed',
      code: response.code?.toString(),
    ));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    emit(RazorpayExternalWallet(response.walletName ?? 'External Wallet'));
  }

  @override
  Future<void> close() {
    _razorpay.clear();
    return super.close();
  }
}
