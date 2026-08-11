
import '../../domain/entities/associate_member_entity.dart';

class AssociateCommitteeMemberModel extends CommitteeMemberEntity {
  const AssociateCommitteeMemberModel({
    required super.id,
    required super.name,
    required super.position,
    required super.photoUrl,
    super.isHighlighted,
  });

  factory AssociateCommitteeMemberModel.fromJson(Map<String, dynamic> json) {
    final tier = json['tier'] as int? ?? 1;
    return AssociateCommitteeMemberModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      position: json['role'] ?? json['position'] ?? '',
      photoUrl: json['photo'] ?? json['photoUrl'] ?? '',
      isHighlighted: tier == 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'position': position,
    'photoUrl': photoUrl,
    'isHighlighted': isHighlighted,
  };
}