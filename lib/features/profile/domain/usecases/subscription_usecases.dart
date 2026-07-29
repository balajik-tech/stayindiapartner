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
