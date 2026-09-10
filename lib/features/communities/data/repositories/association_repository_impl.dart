import '../../domain/entities/associate_member_entity.dart';
import '../../domain/entities/community_wing_entity.dart';
import '../../domain/entities/executive_member_entity.dart';
import '../../domain/entities/it_wing_member_entity.dart';
import '../../domain/entities/port_member_entity.dart';
import '../../domain/entities/executive_structure_entity.dart';
import '../../domain/entities/community_theme_entity.dart';
import '../../domain/entities/association_details_entity.dart';
import '../../domain/entities/association_portal_entity.dart';
import '../../domain/repositories/associate_repository.dart';
import '../datasources/community_static_datasource.dart';

class AssociateRepositoryImpl implements AssociateRepository {
  final AssociateDataSource dataSource;
  const AssociateRepositoryImpl(this.dataSource);

  @override
  Future<List<CommitteeMemberEntity>> getExecutiveCommittee(String associationId) =>
      dataSource.getExecutiveCommittee(associationId);

  @override
  Future<List<ExecutiveMemberEntity>> getExecutiveMembers(String associationId) =>
      dataSource.getExecutiveMembers(associationId);

  @override
  Future<List<ItWingMemberEntity>> getItWingMembers(String associationId) =>
      dataSource.getItWingMembers(associationId);

  @override
  Future<List<PortMemberEntity>> getPortMembers(String associationId) =>
      dataSource.getPortMembers(associationId);

  @override
  Future<List<CommunityWingEntity>> getCommunityWings(String associationId) =>
      dataSource.getCommunityWings(associationId);

  @override
  Future<List<ExecutiveStructureLeaderEntity>> getExecutiveStructure(String execId) =>
      dataSource.getExecutiveStructure(execId);

  @override
  Future<CommunityThemeEntity> getCommunityTheme(String associationId) =>
      dataSource.getCommunityTheme(associationId);

  @override
  Future<AssociationDetailsEntity> getAssociationDetails(String id) =>
      dataSource.getAssociationDetails(id);

  @override
  Future<List<AssociationPortalEntity>> getAssociations() =>
      dataSource.getAssociations();
}
