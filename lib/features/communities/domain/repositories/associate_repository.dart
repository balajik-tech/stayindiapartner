import '../entities/associate_member_entity.dart';
import '../entities/executive_member_entity.dart';
import '../entities/it_wing_member_entity.dart';
import '../entities/port_member_entity.dart';
import '../entities/community_theme_entity.dart';
import '../entities/association_details_entity.dart';
import '../entities/association_portal_entity.dart';

abstract class AssociateRepository {
  Future<List<CommitteeMemberEntity>> getExecutiveCommittee(String associationId);
  Future<List<ExecutiveMemberEntity>> getExecutiveMembers(String associationId);
  Future<List<ItWingMemberEntity>> getItWingMembers(String associationId);
  Future<List<PortMemberEntity>> getPortMembers(String associationId);
  Future<CommunityThemeEntity> getCommunityTheme(String associationId);
  Future<AssociationDetailsEntity> getAssociationDetails(String id);
  Future<List<AssociationPortalEntity>> getAssociations();
}
