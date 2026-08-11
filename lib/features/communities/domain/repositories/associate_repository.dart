import '../entities/associate_member_entity.dart';
import '../entities/executive_member_entity.dart';
import '../entities/it_wing_member_entity.dart';
import '../entities/community_theme_entity.dart';
import '../entities/association_details_entity.dart';

abstract class AssociateRepository {
  Future<List<CommitteeMemberEntity>> getExecutiveCommittee();
  Future<List<ExecutiveMemberEntity>> getExecutiveMembers();
  Future<List<ItWingMemberEntity>> getItWingMembers();
  Future<CommunityThemeEntity> getCommunityTheme();
  Future<AssociationDetailsEntity> getAssociationDetails(String id);
}
