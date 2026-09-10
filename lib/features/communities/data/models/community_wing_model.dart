import '../../domain/entities/community_wing_entity.dart';
import 'committee_member_model.dart';

class CommunityWingModel extends CommunityWingEntity {
  const CommunityWingModel({
    required super.id,
    required super.name,
    required super.description,
    required super.status,
    required super.members,
  });

  factory CommunityWingModel.fromJson(Map<String, dynamic> json) {
    return CommunityWingModel(
      id: json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      members: (json['members'] as List<dynamic>?)
              ?.map((m) => CommunityWingMemberModel.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class CommunityWingMemberModel extends CommunityWingMemberEntity {
  const CommunityWingMemberModel({
    required super.id,
    required super.wingRole,
    required super.details,
  });

  factory CommunityWingMemberModel.fromJson(Map<String, dynamic> json) {
    return CommunityWingMemberModel(
      id: json['_id']?.toString() ?? '',
      wingRole: json['role']?.toString() ?? '',
      details: AssociateCommitteeMemberModel.fromJson(
        json['memberId'] as Map<String, dynamic>? ?? {},
      ),
    );
  }
}
