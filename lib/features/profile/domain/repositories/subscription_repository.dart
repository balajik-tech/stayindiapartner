import '../entities/subscription_response.dart';
import '../entities/payment_summary.dart';
import '../entities/subscription_receipt.dart';

abstract class SubscriptionRepository {
  Future<SubscriptionResponse> getSubscriptionPlans(String propertyId);
  Future<ActiveSubscription> subscribeToPlan(
    String propertyId,
    String planId,
    String paymentMethod,
  );
  Future<Map<String, dynamic>> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  });
  Future<PaymentSummary> getPaymentSummary(String paymentId);
  Future<Map<String, String>> getPaymentReceipt(String paymentId);
  Future<List<SubscriptionReceipt>> getMyReceipts();
}
