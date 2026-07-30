import 'package:dio/dio.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import '../models/subscription_response_model.dart';
import '../models/payment_summary_model.dart';
import '../../domain/entities/subscription_response.dart';

abstract class SubscriptionRemoteDataSource {
  Future<SubscriptionResponseModel> getSubscriptionPlans(String propertyId);
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
  Future<PaymentSummaryModel> getPaymentSummary(String paymentId);
  Future<Map<String, String>> getPaymentReceipt(String paymentId);
}

class SubscriptionRemoteDataSourceImpl implements SubscriptionRemoteDataSource {
  final Dio dio;

  SubscriptionRemoteDataSourceImpl({required this.dio});

  @override
  Future<SubscriptionResponseModel> getSubscriptionPlans(String propertyId) async {
    try {
      final response = await dio.get(
        '${ApiConstants.subscriptionPlans}/$propertyId',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return SubscriptionResponseModel.fromJson(data);
        }
      }
      throw Exception('Failed to load subscription plans');
    } catch (e) {
      throw Exception('Error loading subscription plans: $e');
    }
  }

  @override
  Future<ActiveSubscription> subscribeToPlan(
    String propertyId,
    String planId,
    String paymentMethod,
  ) async {
    try {
      final response = await dio.post(
        ApiConstants.subscriptionSubscribe,
        data: {
          'propertyId': propertyId,
          'planId': planId,
          'paymentMethod': paymentMethod,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          final subscriptionJson = data['subscription'];
          final orderJson = data['order'];
          
          if (subscriptionJson is Map<String, dynamic>) {
            // Merge Razorpay order ID and amount into subscription JSON before parsing
            if (orderJson is Map<String, dynamic>) {
              if (orderJson.containsKey('id')) {
                subscriptionJson['razorpayOrderId'] = orderJson['id'];
              }
              if (orderJson.containsKey('amount')) {
                subscriptionJson['razorpayAmount'] = orderJson['amount'];
              }
            }
            return ActiveSubscriptionModel.fromJson(subscriptionJson);
          }
        }
      }
      throw Exception('Failed to subscribe to plan');
    } catch (e) {
      throw Exception('Error subscribing to plan: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.subscriptionVerifyPayment,
        data: {
          'razorpay_order_id': orderId,
          'razorpay_payment_id': paymentId,
          'razorpay_signature': signature,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return data;
        }
      }
      throw Exception('Payment verification failed');
    } catch (e) {
      throw Exception('Error verifying payment: $e');
    }
  }

  @override
  Future<PaymentSummaryModel> getPaymentSummary(String paymentId) async {
    try {
      final response = await dio.get(
        '${ApiConstants.subscriptionPaymentSummary}/$paymentId/summary',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return PaymentSummaryModel.fromJson(data);
        }
      }
      throw Exception('Failed to load payment summary');
    } catch (e) {
      throw Exception('Error loading payment summary: $e');
    }
  }

  @override
  Future<Map<String, String>> getPaymentReceipt(String paymentId) async {
    try {
      final response = await dio.get(
        '${ApiConstants.subscriptionPaymentReceipt}/$paymentId/receipt',
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        if (data is Map<String, dynamic>) {
          return {
            'fileUrl': data['fileUrl']?.toString() ?? '',
            'fileName': data['fileName']?.toString() ?? '',
          };
        }
      }
      throw Exception('Failed to load payment receipt');
    } catch (e) {
      throw Exception('Error loading payment receipt: $e');
    }
  }
}
