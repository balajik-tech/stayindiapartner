import 'package:dio/dio.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import '../models/committee_member_model.dart';
import '../models/executive_member_model.dart';
import '../models/it_wing_member_model.dart';
import '../models/community_theme_model.dart';
import '../models/association_details_model.dart';
import '../models/association_portal_model.dart';

/// Contract kept separate from the static impl so a future
/// `CommunityRemoteDataSource` (calling the real theme/members API)
/// can be dropped in without touching the repository.
abstract class AssociateDataSource {
  Future<List<AssociateCommitteeMemberModel>> getExecutiveCommittee(String associationId);
  Future<List<AssociateExecutiveMemberModel>> getExecutiveMembers(String associationId);
  Future<List<AssociateItWingMemberModel>> getItWingMembers(String associationId);
  Future<AssociateCommunityThemeModel> getCommunityTheme(String associationId);
  Future<AssociationDetailsModel> getAssociationDetails(String id);
  Future<List<AssociationPortalModel>> getAssociations();
}

class AssociateStaticDataSource implements AssociateDataSource {
  final Dio _dio;
  const AssociateStaticDataSource(this._dio);

  @override
  Future<List<AssociationPortalModel>> getAssociations() async {
    final response = await _dio.get(ApiConstants.associationsPortal);
    if (response.statusCode == 200) {
      final raw = response.data;
      final data = raw['data'] as Map<String, dynamic>;
      final list = data['associations'] as List;
      return list.map((json) => AssociationPortalModel.fromJson(json)).toList();
    }
    throw Exception('Failed to fetch associations');
  }

  @override
  Future<List<AssociateCommitteeMemberModel>> getExecutiveCommittee(String associationId) async {
    final response = await _dio.get('${ApiConstants.associationWorkingBody}/$associationId');
    if (response.statusCode == 200) {
      final raw = response.data;
      final data = raw['data'] as Map<String, dynamic>;
      final list = data['roles'] as List;
      return list.map((json) => AssociateCommitteeMemberModel.fromJson(json)).toList();
    }
    throw Exception('Failed to fetch executive committee');
  }

  @override
  Future<List<AssociateExecutiveMemberModel>> getExecutiveMembers(String associationId) async {
    final response = await _dio.get('${ApiConstants.associationExecutiveMembers}/$associationId');
    if (response.statusCode == 200) {
      final raw = response.data;
      final data = raw['data'] as Map<String, dynamic>;
      final list = data['roles'] as List;
      return list.map((json) => AssociateExecutiveMemberModel.fromJson(json)).toList();
    }
    throw Exception('Failed to fetch executive members');
  }

  @override
  Future<List<AssociateItWingMemberModel>> getItWingMembers(String associationId) async {
    final response = await _dio.get('${ApiConstants.associationTeamLeads}/$associationId');
    if (response.statusCode == 200) {
      final raw = response.data;
      final data = raw['data'] as Map<String, dynamic>;
      final list = data['roles'] as List;
      return list.map((json) => AssociateItWingMemberModel.fromJson(json)).toList();
    }
    throw Exception('Failed to fetch IT wing members');
  }

  @override
  Future<AssociateCommunityThemeModel> getCommunityTheme(String associationId) async {
    return const AssociateCommunityThemeModel(
      primaryColor: '#16305A', // top card & membership card & card title & count in card color change
      primaryColorLight: '#1E4976', // gradient background color for top card
      accentColor: '#6FA641', // tamil nadu text color
      backgroundColor: '#EEF1F6', // background color
      cardColor: '#FFFFFF',  // accordion card color
      textOnPrimary: '#FFFFFF',
      textPrimary: '#1A1A1A', // card each user name color
      textSecondary: '#6B7280', // subtext inside card under sub header & each user (State Vice President
      badgeBackground: '#E7F0DD',//badge background color
      badgeBorder: '#9CCB6B', //badge border
      badgeText: '#3E7A34', //badge background color
    );
  }

  @override
  Future<AssociationDetailsModel> getAssociationDetails(String id) async {
    final response = await _dio.get('${ApiConstants.associationPortalDetails}/$id');
    if (response.statusCode == 200) {
      final raw = response.data;
      final data = raw['data'] as Map<String, dynamic>;
      return AssociationDetailsModel.fromJson(data);
    }
    throw Exception('Failed to load association details');
  }
}
