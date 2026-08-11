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
  Future<List<AssociateCommitteeMemberModel>> getExecutiveCommittee();
  Future<List<AssociateExecutiveMemberModel>> getExecutiveMembers();
  Future<List<AssociateItWingMemberModel>> getItWingMembers();
  Future<AssociateCommunityThemeModel> getCommunityTheme();
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
  Future<List<AssociateCommitteeMemberModel>> getExecutiveCommittee() async {
    return const [
      AssociateCommitteeMemberModel(
        id: 'TNIT-EC-01',
        name: 'Name',
        position: 'STATE PRESIDENT',
        photoUrl: '',
        isHighlighted: true,
      ),
      AssociateCommitteeMemberModel(
        id: 'TNIT-EC-02',
        name: 'Name',
        position: 'STATE SECRETARY',
        photoUrl: '',
        isHighlighted: true,
      ),
      AssociateCommitteeMemberModel(
        id: 'TNIT-EC-03',
        name: 'Name',
        position: 'STATE TREASURER',
        photoUrl: '',
        isHighlighted: true,
      ),
      AssociateCommitteeMemberModel(
        id: 'TNIT-EC-04',
        name: 'Name',
        position: 'STATE VICE PRESIDENT',
        photoUrl: '',
      ),
      AssociateCommitteeMemberModel(
        id: 'TNIT-EC-05',
        name: 'Name',
        position: 'STATE VICE PRESIDENT',
        photoUrl: '',
      ),
      AssociateCommitteeMemberModel(
        id: 'TNIT-EC-06',
        name: 'Name',
        position: 'STATE JOINT SECRETARY',
        photoUrl: '',
      ),
      AssociateCommitteeMemberModel(
        id: 'TNIT-EC-07',
        name: 'Name',
        position: 'STATE JOINT SECRETARY',
        photoUrl: '',
      ),
    ];
  }

  @override
  Future<List<AssociateExecutiveMemberModel>> getExecutiveMembers() async {
    return const [
      AssociateExecutiveMemberModel(
        id: 'TNIT-EXE-001',
        name: 'N. Ganesh',
        zone: 'Chennai Zone',
        photoUrl: '',
        coreMembers: [
          CoreMemberModel(id: 'TNIT-COR-0001', name: 'L. Bala', photoUrl: ''),
          CoreMemberModel(id: 'TNIT-COR-0002', name: 'V. Senthil', photoUrl: ''),
        ],
      ),
      AssociateExecutiveMemberModel(id: 'TNIT-EXE-002', name: 'P. Selvam', zone: 'Coimbatore Zone', photoUrl: ''),
      AssociateExecutiveMemberModel(id: 'TNIT-EXE-003', name: 'K. Sivakumar', zone: 'Madurai Zone', photoUrl: ''),
      AssociateExecutiveMemberModel(id: 'TNIT-EXE-004', name: 'G. Bala', zone: 'Trichy Zone', photoUrl: ''),
      AssociateExecutiveMemberModel(id: 'TNIT-EXE-005', name: 'E. Thiru', zone: 'Salem Zone', photoUrl: ''),
      AssociateExecutiveMemberModel(id: 'TNIT-EXE-006', name: 'D. Vignesh', zone: 'Tirunelveli Zone', photoUrl: ''),
      AssociateExecutiveMemberModel(id: 'TNIT-EXE-007', name: 'C. Praveen', zone: 'Erode Zone', photoUrl: ''),
      AssociateExecutiveMemberModel(id: 'TNIT-EXE-008', name: 'V. Praveen', zone: 'Vellore Zone', photoUrl: ''),
      AssociateExecutiveMemberModel(id: 'TNIT-EXE-009', name: 'R. Suresh', zone: 'Thanjavur Zone', photoUrl: ''),
    ];
  }

  @override
  Future<List<AssociateItWingMemberModel>> getItWingMembers() async {
    return const [
      AssociateItWingMemberModel(id: 'TNIT-ITW-01', name: 'R. Vijay', role: 'IT WING', photoUrl: ''),
      AssociateItWingMemberModel(id: 'TNIT-ITW-02', name: 'T. Bharath', role: 'IT WING', photoUrl: ''),
      AssociateItWingMemberModel(id: 'TNIT-ITW-03', name: 'S. Gopal', role: 'IT WING', photoUrl: ''),
      AssociateItWingMemberModel(id: 'TNIT-ITW-04', name: 'C. Murugan', role: 'IT WING', photoUrl: ''),
      AssociateItWingMemberModel(id: 'TNIT-ITW-05', name: 'L. Madhan', role: 'IT WING', photoUrl: ''),
    ];
  }

  @override
  Future<AssociateCommunityThemeModel> getCommunityTheme() async {
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
