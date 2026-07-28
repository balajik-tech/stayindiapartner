import 'package:equatable/equatable.dart';
import '../../domain/entities/razorpay_payment_result.dart';

abstract class RazorpayState extends Equatable {
  const RazorpayState();

  @override
  List<Object?> get props => [];
}

class RazorpayInitial extends RazorpayState {}

class RazorpayOpeningCheckout extends RazorpayState {}

class RazorpaySuccess extends RazorpayState {
  final RazorpayPaymentResult result;
  const RazorpaySuccess(this.result);

  @override
  List<Object?> get props => [result];
}

class RazorpayFailure extends RazorpayState {
  final String message;
  final String? code;
  const RazorpayFailure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

class RazorpayExternalWallet extends RazorpayState {
  final String walletName;
  const RazorpayExternalWallet(this.walletName);

  @override
  List<Object?> get props => [walletName];
}
