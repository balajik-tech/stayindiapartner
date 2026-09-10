import 'package:equatable/equatable.dart';
import 'associate_member_entity.dart';

class CommunityWingEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String status;
  final List<CommunityWingMemberEntity> members;

  const CommunityWingEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.status,
    required this.members,
  });

  @override
  List<Object?> get props => [id, name, description, status, members];
}

class CommunityWingMemberEntity extends Equatable {
  final String id;
  final String wingRole; // LEAD, COORDINATOR
  final CommitteeMemberEntity details;

  const CommunityWingMemberEntity({
    required this.id,
    required this.wingRole,
    required this.details,
  });

  @override
  List<Object?> get props => [id, wingRole, details];
}
