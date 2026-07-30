part of 'subscription_cubit.dart';

abstract class SubscriptionState extends Equatable {
  final Map<String, SubscriptionResponse> subscriptionResponses;

  const SubscriptionState({this.subscriptionResponses = const {}});

  @override
  List<Object?> get props => [subscriptionResponses];
}

class SubscriptionInitial extends SubscriptionState {
  const SubscriptionInitial({Map<String, SubscriptionResponse> subscriptionResponses = const {}})
      : super(subscriptionResponses: subscriptionResponses);
}

class SubscriptionLoading extends SubscriptionState {
  final String? loadingPropertyId;

  const SubscriptionLoading({
    Map<String, SubscriptionResponse> subscriptionResponses = const {},
    this.loadingPropertyId,
  }) : super(subscriptionResponses: subscriptionResponses);

  @override
  List<Object?> get props => [subscriptionResponses, loadingPropertyId];
}

class SubscriptionLoaded extends SubscriptionState {
  const SubscriptionLoaded({required Map<String, SubscriptionResponse> subscriptionResponses})
      : super(subscriptionResponses: subscriptionResponses);
}

class SubscriptionProcessing extends SubscriptionState {
  final String propertyId;

  const SubscriptionProcessing({
    required this.propertyId,
    Map<String, SubscriptionResponse> subscriptionResponses = const {},
  }) : super(subscriptionResponses: subscriptionResponses);

  @override
  List<Object?> get props => [subscriptionResponses, propertyId];
}

class SubscriptionSubscribed extends SubscriptionState {
  final ActiveSubscription activeSubscription;

  const SubscriptionSubscribed({
    required this.activeSubscription,
    required Map<String, SubscriptionResponse> subscriptionResponses,
  }) : super(subscriptionResponses: subscriptionResponses);

  @override
  List<Object?> get props => [subscriptionResponses, activeSubscription];
}

class SubscriptionPaymentVerified extends SubscriptionState {
  final String message;

  const SubscriptionPaymentVerified({
    required this.message,
    Map<String, SubscriptionResponse> subscriptionResponses = const {},
  }) : super(subscriptionResponses: subscriptionResponses);

  @override
  List<Object?> get props => [subscriptionResponses, message];
}

class SubscriptionPaymentVerificationFailed extends SubscriptionState {
  final String message;

  const SubscriptionPaymentVerificationFailed({
    required this.message,
    Map<String, SubscriptionResponse> subscriptionResponses = const {},
  }) : super(subscriptionResponses: subscriptionResponses);

  @override
  List<Object?> get props => [subscriptionResponses, message];
}

class SubscriptionError extends SubscriptionState {
  final String message;

  const SubscriptionError({
    required this.message,
    Map<String, SubscriptionResponse> subscriptionResponses = const {},
  }) : super(subscriptionResponses: subscriptionResponses);

  @override
  List<Object?> get props => [subscriptionResponses, message];
}
