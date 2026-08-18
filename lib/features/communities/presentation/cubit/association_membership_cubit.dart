import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/association_membership_entity.dart';
import '../../domain/usecases/association_membership_usecases.dart';

abstract class AssociationMembershipState extends Equatable {
  const AssociationMembershipState();
  @override
  List<Object?> get props => [];
}

class AssociationMembershipInitial extends AssociationMembershipState {}

class AssociationMembershipLoading extends AssociationMembershipState {}

class AssociationMembershipLoaded extends AssociationMembershipState {
  final AssociationMembershipEntity? membership;
  final List<MembershipPropertyEntity> eligibleProperties;
  final MembershipPaymentDetailsEntity? paymentDetails;
  final String status; // For newUser, applied, etc.

  const AssociationMembershipLoaded({
    this.membership,
    this.eligibleProperties = const [],
    this.paymentDetails,
    required this.status,
  });

  @override
  List<Object?> get props => [membership, eligibleProperties, paymentDetails, status];
}

class AssociationMembershipError extends AssociationMembershipState {
  final String message;
  const AssociationMembershipError(this.message);
  @override
  List<Object?> get props => [message];
}

class AssociationMembershipCubit extends Cubit<AssociationMembershipState> {
  final GetMyAssociationApplicationsUseCase getMyApplications;
  final GetEligibleMembershipPropertiesUseCase getEligibleProperties;
  final SubmitMembershipApplicationUseCase submitApplication;
  final GetMembershipPaymentDetailsUseCase getPaymentDetails;
  final CreateMembershipPaymentOrderUseCase createPaymentOrder;
  final CreateMembershipRenewalOrderUseCase createRenewalOrder;
  final VerifyMembershipPaymentUseCase verifyPaymentUseCase;

  AssociationMembershipCubit({
    required this.getMyApplications,
    required this.getEligibleProperties,
    required this.submitApplication,
    required this.getPaymentDetails,
    required this.createPaymentOrder,
    required this.createRenewalOrder,
    required this.verifyPaymentUseCase,
  }) : super(AssociationMembershipInitial());

  Future<void> loadMembershipData(String portalId) async {
    if (portalId.isEmpty) {
      AppLogger.warning('loadMembershipData called with empty portalId');
      return;
    }
    emit(AssociationMembershipLoading());
    try {
      final applications = await getMyApplications(portalId);
      final eligible = await getEligibleProperties();
      
      String status = 'NEW_USER';
      AssociationMembershipEntity? firstMembership;
      MembershipPaymentDetailsEntity? paymentDetails;
      
      if (applications.isNotEmpty) {
        firstMembership = applications.first;
        status = firstMembership.status.toUpperCase().trim();

        AppLogger.debug('Association Status: $status');

        // Fetch payment details for statuses that require payment
        final paymentRequiredStatuses = [
          'APPROVED',
          'PAYMENT_PENDING',
          'APPROVED_PENDING_PAYMENT',
          'PENDING_APPROVAL', // Added this just in case
          'PENDING_PAYMENT'
        ];

        if (paymentRequiredStatuses.contains(status)) {
          try {
            AppLogger.info('Attempting to fetch payment details for membership ID: ${firstMembership.id}');
            paymentDetails = await getPaymentDetails(firstMembership.id);
            AppLogger.success('Successfully fetched payment details. Amount: ${paymentDetails.amount}');
          } catch (e) {
            AppLogger.error('API Error fetching payment details for ${firstMembership.id}: $e');
          }
        } else {
          AppLogger.warning('Status $status not in paymentRequiredStatuses list');
        }
      }
      
      emit(AssociationMembershipLoaded(
        membership: firstMembership,
        eligibleProperties: eligible,
        paymentDetails: paymentDetails,
        status: status,
      ));
    } catch (e) {
      AppLogger.error('loadMembershipData error: $e');
      emit(AssociationMembershipError(e.toString()));
    }
  }

  Future<void> refreshPaymentDetails(String membershipId) async {
    final currentState = state;
    if (currentState is AssociationMembershipLoaded) {
      try {
        AppLogger.info('Refreshing payment details for $membershipId');
        final details = await getPaymentDetails(membershipId);
        emit(AssociationMembershipLoaded(
          membership: currentState.membership,
          eligibleProperties: currentState.eligibleProperties,
          paymentDetails: details,
          status: currentState.status,
        ));
      } catch (e) {
        AppLogger.error('refreshPaymentDetails error: $e');
      }
    }
  }

  Future<Map<String, dynamic>?> generatePaymentOrder(String membershipId) async {
    try {
      AppLogger.info('Creating payment order for membership: $membershipId');
      return await createPaymentOrder(membershipId);
    } catch (e) {
      AppLogger.error('Failed to create payment order: $e');
      emit(AssociationMembershipError(e.toString()));
      return null;
    }
  }

  Future<Map<String, dynamic>?> generateRenewalOrder(String membershipId) async {
    try {
      AppLogger.info('Creating renewal order for membership: $membershipId');
      return await createRenewalOrder(membershipId);
    } catch (e) {
      AppLogger.error('Failed to create renewal order: $e');
      emit(AssociationMembershipError(e.toString()));
      return null;
    }
  }

  Future<void> verifyPayment({
    required String portalId,
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    emit(AssociationMembershipLoading());
    try {
      final success = await verifyPaymentUseCase(
        orderId: orderId,
        paymentId: paymentId,
        signature: signature,
      );
      if (success) {
        await loadMembershipData(portalId);
      } else {
        emit(const AssociationMembershipError('Payment verification failed'));
      }
    } catch (e) {
      emit(AssociationMembershipError(e.toString()));
    }
  }

  Future<void> submit(String portalId, List<String> propertyIds) async {
    emit(AssociationMembershipLoading());
    try {
      await submitApplication(
        portalId: portalId,
        propertyIds: propertyIds,
      );
      await loadMembershipData(portalId);
    } catch (e) {
      emit(AssociationMembershipError(e.toString()));
    }
  }
}
