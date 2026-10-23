part of 'subscription_cubit.dart';

abstract class SubscriptionState extends Equatable {
  final Map<String, SubscriptionResponse> subscriptionResponses;

  const SubscriptionState({this.subscriptionResponses = const {}});

  @override
  List<Object?> get props => [subscriptionResponses];
}

class SubscriptionInitial extends SubscriptionState {
  const SubscriptionInitial({super.subscriptionResponses});
}

class SubscriptionLoading extends SubscriptionState {
  final String? loadingPropertyId;

  const SubscriptionLoading({
    super.subscriptionResponses,
    this.loadingPropertyId,
  });

  @override
  List<Object?> get props => [subscriptionResponses, loadingPropertyId];
}

class SubscriptionLoaded extends SubscriptionState {
  const SubscriptionLoaded({required super.subscriptionResponses});
}

class SubscriptionProcessing extends SubscriptionState {
  final String propertyId;

  const SubscriptionProcessing({
    required this.propertyId,
    super.subscriptionResponses,
  });

  @override
  List<Object?> get props => [subscriptionResponses, propertyId];
}

class SubscriptionSubscribed extends SubscriptionState {
  final ActiveSubscription activeSubscription;

  const SubscriptionSubscribed({
    required this.activeSubscription,
    required super.subscriptionResponses,
  });

  @override
  List<Object?> get props => [subscriptionResponses, activeSubscription];
}

class SubscriptionPaymentVerified extends SubscriptionState {
  final String message;
  final PaymentSummary summary;

  const SubscriptionPaymentVerified({
    required this.message,
    required this.summary,
    super.subscriptionResponses,
  });

  @override
  List<Object?> get props => [subscriptionResponses, message, summary];
}

class SubscriptionPaymentVerificationFailed extends SubscriptionState {
  final String message;
  final PaymentSummary? summary;

  const SubscriptionPaymentVerificationFailed({
    required this.message,
    this.summary,
    super.subscriptionResponses,
  });

  @override
  List<Object?> get props => [subscriptionResponses, message, summary];
}

class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError({
    required this.message,
    super.subscriptionResponses,
  });

  @override
  List<Object?> get props => [subscriptionResponses, message];
}
