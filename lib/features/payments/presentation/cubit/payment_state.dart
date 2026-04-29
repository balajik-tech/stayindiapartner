part of 'payment_cubit.dart';

abstract class PaymentState {}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentLoaded extends PaymentState {
  final HostelPaymentSummary summary;
  PaymentLoaded({required this.summary});
}

class PaymentPaying extends PaymentState {}

class PaymentReminding extends PaymentState {}

class PaymentSuccess extends PaymentState {
  final String message;
  final bool shouldRefresh;
  PaymentSuccess({required this.message, this.shouldRefresh = false});
}

class PaymentError extends PaymentState {
  final String message;
  PaymentError({required this.message});
}
