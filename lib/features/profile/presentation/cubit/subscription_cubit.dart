import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/subscription_response.dart';
import '../../domain/usecases/subscription_usecases.dart';

part 'subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final GetSubscriptionPlansUseCase _getSubscriptionPlans;
  final SubscribeToPlanUseCase _subscribeToPlan;

  SubscriptionCubit({
    required GetSubscriptionPlansUseCase getSubscriptionPlansUseCase,
    required SubscribeToPlanUseCase subscribeToPlanUseCase,
  })  : _getSubscriptionPlans = getSubscriptionPlansUseCase,
        _subscribeToPlan = subscribeToPlanUseCase,
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
}
