import '../entities/subscription_response.dart';

abstract class SubscriptionRepository {
  Future<SubscriptionResponse> getSubscriptionPlans(String propertyId);
  Future<ActiveSubscription> subscribeToPlan(
    String propertyId,
    String planId,
    String paymentMethod,
  );
  Future<bool> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  });
}
