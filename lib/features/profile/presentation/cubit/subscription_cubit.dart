import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/subscription_response.dart';
import '../../domain/entities/payment_summary.dart';
import '../../domain/usecases/subscription_usecases.dart';

part 'subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final GetSubscriptionPlansUseCase _getSubscriptionPlans;
  final SubscribeToPlanUseCase _subscribeToPlan;
  final VerifySubscriptionPaymentUseCase _verifyPayment;
  final GetPaymentSummaryUseCase _getPaymentSummary;

  SubscriptionCubit({
    required GetSubscriptionPlansUseCase getSubscriptionPlansUseCase,
    required SubscribeToPlanUseCase subscribeToPlanUseCase,
    required VerifySubscriptionPaymentUseCase verifyPaymentUseCase,
    required GetPaymentSummaryUseCase getPaymentSummaryUseCase,
  })  : _getSubscriptionPlans = getSubscriptionPlansUseCase,
        _subscribeToPlan = subscribeToPlanUseCase,
        _verifyPayment = verifyPaymentUseCase,
        _getPaymentSummary = getPaymentSummaryUseCase,
        super(SubscriptionInitial());

  Future<void> loadSubscriptionPlans(String propertyId, {bool forceRefresh = false}) async {
    if (!forceRefresh && state.subscriptionResponses.containsKey(propertyId)) {
      return;
    }

    if (state is SubscriptionLoading && (state as SubscriptionLoading).loadingPropertyId == propertyId) {
      return;
    }

    emit(SubscriptionLoading(
      subscriptionResponses: state.subscriptionResponses,
      loadingPropertyId: propertyId,
    ));
    try {
      final response = await _getSubscriptionPlans(propertyId);
      final updatedResponses = Map<String, SubscriptionResponse>.from(state.subscriptionResponses);
      updatedResponses[propertyId] = response;
      emit(SubscriptionLoaded(subscriptionResponses: updatedResponses));
    } catch (e) {
      emit(SubscriptionError(
        message: e.toString(),
        subscriptionResponses: state.subscriptionResponses,
      ));
    }
  }

  Future<void> subscribe(
    String propertyId,
    String planId,
    String paymentMethod,
  ) async {
    emit(SubscriptionProcessing(
      propertyId: propertyId,
      subscriptionResponses: state.subscriptionResponses,
    ));
    try {
      final activeSubscription = await _subscribeToPlan(propertyId, planId, paymentMethod);
      final updatedResponses = Map<String, SubscriptionResponse>.from(state.subscriptionResponses);
      
      if (updatedResponses.containsKey(propertyId)) {
        final currentResponse = updatedResponses[propertyId]!;
        updatedResponses[propertyId] = SubscriptionResponse(
          property: currentResponse.property,
          plans: currentResponse.plans,
          activeSubscription: activeSubscription,
        );
      }
      
      emit(SubscriptionSubscribed(
        activeSubscription: activeSubscription,
        subscriptionResponses: updatedResponses,
      ));
    } catch (e) {
      emit(SubscriptionError(
        message: e.toString(),
        subscriptionResponses: state.subscriptionResponses,
      ));
    }
  }

  Future<void> verifyPayment({
    required String propertyId,
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    emit(SubscriptionProcessing(
      propertyId: propertyId,
      subscriptionResponses: state.subscriptionResponses,
    ));
    try {
      final verificationResult = await _verifyPayment(
        orderId: orderId,
        paymentId: paymentId,
        signature: signature,
      );

      final isVerified = verificationResult['verified'] == true;
      final serverPaymentId = verificationResult['paymentId']?.toString();

      if (isVerified && serverPaymentId != null) {
        final summary = await _getPaymentSummary(serverPaymentId);
        await loadSubscriptionPlans(propertyId, forceRefresh: true);
        emit(SubscriptionPaymentVerified(
          message: "Payment verified successfully",
          summary: summary,
          subscriptionResponses: state.subscriptionResponses,
        ));
      } else {
        // Even if verified is false, we might want to fetch summary if paymentId exists to show reason
        PaymentSummary? summary;
        if (serverPaymentId != null) {
          try {
            summary = await _getPaymentSummary(serverPaymentId);
          } catch (_) {}
        }
        
        emit(SubscriptionPaymentVerificationFailed(
          message: "Payment verification failed",
          summary: summary,
          subscriptionResponses: state.subscriptionResponses,
        ));
      }
    } catch (e) {
      emit(SubscriptionPaymentVerificationFailed(
        message: e.toString(),
        subscriptionResponses: state.subscriptionResponses,
      ));
    }
  }
}
