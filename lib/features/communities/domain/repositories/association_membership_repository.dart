import '../entities/association_membership_entity.dart';

abstract class AssociationMembershipRepository {
  Future<List<AssociationMembershipEntity>> getMyApplications(String portalId);
  Future<List<MembershipPropertyEntity>> getEligibleProperties();
  Future<AssociationMembershipEntity> submitApplication({
    required String portalId,
    required List<String> propertyIds,
  });
}
