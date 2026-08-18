import 'dart:io';
import '../entities/association_membership_entity.dart';
import '../repositories/association_membership_repository.dart';

class GetMyAssociationApplicationsUseCase {
  final AssociationMembershipRepository repository;
  GetMyAssociationApplicationsUseCase(this.repository);

  Future<List<AssociationMembershipEntity>> call(String portalId) {
    return repository.getMyApplications(portalId);
  }
}

class GetEligibleMembershipPropertiesUseCase {
  final AssociationMembershipRepository repository;
  GetEligibleMembershipPropertiesUseCase(this.repository);

  Future<List<MembershipPropertyEntity>> call() {
    return repository.getEligibleProperties();
  }
}

class SubmitMembershipApplicationUseCase {
  final AssociationMembershipRepository repository;
  SubmitMembershipApplicationUseCase(this.repository);

  Future<AssociationMembershipEntity> call({
    required String portalId,
    required List<String> propertyIds,
  }) {
    return repository.submitApplication(
      portalId: portalId,
      propertyIds: propertyIds,
    );
  }
}

class GetMembershipPaymentDetailsUseCase {
  final AssociationMembershipRepository repository;
  GetMembershipPaymentDetailsUseCase(this.repository);

  Future<MembershipPaymentDetailsEntity> call(String membershipId) {
    return repository.getPaymentDetails(membershipId);
  }
}

class CreateMembershipPaymentOrderUseCase {
  final AssociationMembershipRepository repository;
  CreateMembershipPaymentOrderUseCase(this.repository);

  Future<Map<String, dynamic>> call(String membershipId) {
    return repository.createPaymentOrder(membershipId);
  }
}

class CreateMembershipRenewalOrderUseCase {
  final AssociationMembershipRepository repository;
  CreateMembershipRenewalOrderUseCase(this.repository);

  Future<Map<String, dynamic>> call(String membershipId) {
    return repository.createRenewalOrder(membershipId);
  }
}

class VerifyMembershipPaymentUseCase {
  final AssociationMembershipRepository repository;
  VerifyMembershipPaymentUseCase(this.repository);

  Future<bool> call({
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
