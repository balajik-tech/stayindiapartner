import '../entities/subscription_response.dart';
import '../entities/payment_summary.dart';
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

  Future<Map<String, dynamic>> call({
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

class GetPaymentSummaryUseCase {
  final SubscriptionRepository repository;

  GetPaymentSummaryUseCase(this.repository);

  Future<PaymentSummary> call(String paymentId) {
    return repository.getPaymentSummary(paymentId);
  }
}
