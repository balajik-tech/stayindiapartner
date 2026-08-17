import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
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
  final String status; // For newUser, applied, etc.

  const AssociationMembershipLoaded({
    this.membership,
    this.eligibleProperties = const [],
    required this.status,
  });

  @override
  List<Object?> get props => [membership, eligibleProperties, status];
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

  AssociationMembershipCubit({
    required this.getMyApplications,
    required this.getEligibleProperties,
    required this.submitApplication,
  }) : super(AssociationMembershipInitial());

  Future<void> loadMembershipData(String portalId) async {
    emit(AssociationMembershipLoading());
    try {
      final applications = await getMyApplications(portalId);
      final eligible = await getEligibleProperties();
      
      String status = 'NEW_USER';
      AssociationMembershipEntity? firstMembership;
      
      if (applications.isNotEmpty) {
        firstMembership = applications.first;
        status = firstMembership.status;
      }
      
      emit(AssociationMembershipLoaded(
        membership: firstMembership,
        eligibleProperties: eligible,
        status: status,
      ));
    } catch (e) {
      emit(AssociationMembershipError(e.toString()));
    }
  }

  Future<void> submit(String portalId, List<String> propertyIds) async {
    // We might want a "Submitting" sub-state or just keep loading
    try {
      final newMembership = await submitApplication(
        portalId: portalId,
        propertyIds: propertyIds,
      );
      // After submission, reload all data to be sure
      await loadMembershipData(portalId);
    } catch (e) {
      emit(AssociationMembershipError(e.toString()));
    }
  }
}
