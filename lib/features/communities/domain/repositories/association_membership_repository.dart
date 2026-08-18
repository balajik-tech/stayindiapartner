import '../entities/association_membership_entity.dart';

abstract class AssociationMembershipRepository {
  Future<List<AssociationMembershipEntity>> getMyApplications(String portalId);
  Future<List<MembershipPropertyEntity>> getEligibleProperties();
  Future<AssociationMembershipEntity> submitApplication({
    required String portalId,
    required List<String> propertyIds,
  });
  Future<MembershipPaymentDetailsEntity> getPaymentDetails(String membershipId);
  Future<Map<String, dynamic>> createPaymentOrder(String membershipId);
  Future<Map<String, dynamic>> createRenewalOrder(String membershipId);
  Future<bool> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  });
}
