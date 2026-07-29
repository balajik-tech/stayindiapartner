import 'package:dio/dio.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import '../models/subscription_response_model.dart';
import '../../domain/entities/subscription_response.dart';

abstract class SubscriptionRemoteDataSource {
  Future<SubscriptionResponseModel> getSubscriptionPlans(String propertyId);
  Future<ActiveSubscription> subscribeToPlan(
    String propertyId,
    String planId,
    String paymentMethod,
  );
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
          final subscription = data['subscription'];
          if (subscription is Map<String, dynamic>) {
            return ActiveSubscriptionModel.fromJson(subscription);
          }
        }
      }
      throw Exception('Failed to subscribe to plan');
    } catch (e) {
      throw Exception('Error subscribing to plan: $e');
    }
  }
}
