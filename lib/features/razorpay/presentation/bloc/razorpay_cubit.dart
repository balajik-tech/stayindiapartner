import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../domain/entities/razorpay_payment_result.dart';
import '../utils/razorpay_manager.dart';
import 'razorpay_state.dart';

class RazorpayCubit extends Cubit<RazorpayState> {
  final RazorpayManager _razorpayManager;

  RazorpayCubit(this._razorpayManager) : super(RazorpayInitial());

  void _setupListeners() {
    _razorpayManager.instance.clear(); // Clear to ensure we are the only listener
    _razorpayManager.instance.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpayManager.instance.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpayManager.instance.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
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
    _setupListeners();
    debugPrint("RAZORPAY_CUBIT_OPENING: amount=$amount, orderId=$orderId");
    emit(RazorpayOpeningCheckout());

    final options = {
      'key': apiKey,
      'amount': amount,
      'name': name,
      'description': description ?? '',
      'prefill': {
        'contact': ?contact,
        'email': ?email,
      },
      'external': {
        'wallets': ['paytm']
      }
    };

    if (orderId.isNotEmpty && !orderId.startsWith("order_test_")) {
      options['order_id'] = orderId;
    }

    try {
      _razorpayManager.instance.open(options);
    } catch (e) {
      debugPrint("RAZORPAY_CUBIT_EXCEPTION: $e");
      emit(RazorpayFailure("Could not open Razorpay checkout: ${e.toString()}"));
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    _razorpayManager.logSuccess(response);
    
    emit(RazorpaySuccess(
      RazorpayPaymentResult.success(
        paymentId: response.paymentId,
        orderId: response.orderId,
        signature: response.signature,
      ),
    ));
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    _razorpayManager.logFailure(response);
    
    emit(RazorpayFailure(
      response.message ?? 'Payment Failed',
      code: response.code?.toString(),
    ));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint("EXTERNAL_WALLET: ${response.walletName}");
    emit(RazorpayExternalWallet(response.walletName ?? 'External Wallet'));
  }

  @override
  Future<void> close() {
    // We don't want to clear shared listeners here if other things are using them,
    // but RazorpayCubit is a factory and usually the only listener for a specific checkout screen.
    // However, since Manager is a singleton, clearing here might affect other flows.
    // For now, let's keep it safe.
    return super.close();
  }
}
