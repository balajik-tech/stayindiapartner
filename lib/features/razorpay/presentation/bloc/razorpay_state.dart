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
  final DateTime timestamp;
  
  RazorpaySuccess(this.result) : timestamp = DateTime.now();

  @override
  List<Object?> get props => [result, timestamp];
}

class RazorpayFailure extends RazorpayState {
  final String message;
  final String? code;
  final DateTime timestamp;

  RazorpayFailure(this.message, {this.code}) : timestamp = DateTime.now();

  @override
  List<Object?> get props => [message, code, timestamp];
}

class RazorpayExternalWallet extends RazorpayState {
  final String walletName;
  const RazorpayExternalWallet(this.walletName);

  @override
  List<Object?> get props => [walletName];
}
