import '../../domain/entities/subscription_response.dart';
import '../../domain/entities/payment_summary.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_remote_datasource.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionRemoteDataSource remoteDataSource;

  SubscriptionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<SubscriptionResponse> getSubscriptionPlans(String propertyId) {
    return remoteDataSource.getSubscriptionPlans(propertyId);
  }

  @override
  Future<ActiveSubscription> subscribeToPlan(
    String propertyId,
    String planId,
    String paymentMethod,
  ) {
    return remoteDataSource.subscribeToPlan(propertyId, planId, paymentMethod);
  }

  @override
  Future<Map<String, dynamic>> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) {
    return remoteDataSource.verifyPayment(
      orderId: orderId,
      paymentId: paymentId,
      signature: signature,
    );
  }

  @override
  Future<PaymentSummary> getPaymentSummary(String paymentId) {
    return remoteDataSource.getPaymentSummary(paymentId);
  }
}
