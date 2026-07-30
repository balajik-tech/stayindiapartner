import '../entities/subscription_response.dart';
import '../repositories/subscription_repository.dart';

class GetSubscriptionPlansUseCase {
  final SubscriptionRepository repository;

  GetSubscriptionPlansUseCase(this.repository);

  Future<SubscriptionResponse> call(String propertyId) {
    return repository.getSubscriptionPlans(propertyId);
  }
}

class SubscribeToPlanUseCase {
  final SubscriptionRepository repository;

  SubscribeToPlanUseCase(this.repository);

  Future<ActiveSubscription> call(
    String propertyId,
    String planId,
    String paymentMethod,
  ) {
    return repository.subscribeToPlan(propertyId, planId, paymentMethod);
  }
}

class VerifySubscriptionPaymentUseCase {
  final SubscriptionRepository repository;

  VerifySubscriptionPaymentUseCase(this.repository);

  Future<bool> call({
    required String orderId,
    required String paymentId,
    required String signature,
  }) {
    return repository.verifyPayment(
      orderId: orderId,
      paymentId: paymentId,
      signature: signature,
    );
  }
}
