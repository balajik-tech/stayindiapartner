
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
    return AssociateCommitteeMemberModel(
      id: json['id'] as String,
      name: json['name'] as String,
      position: json['position'] as String,
      photoUrl: json['photoUrl'] as String,
      isHighlighted: json['isHighlighted'] as bool? ?? false,
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