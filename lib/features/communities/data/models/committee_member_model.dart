
import '../../domain/entities/associate_member_entity.dart';

class AssociateCommitteeMemberModel extends CommitteeMemberEntity {
  const AssociateCommitteeMemberModel({
    required super.id,
    required super.name,
    required super.position,
    required super.photoUrl,
    required super.phone,
    super.isHighlighted,
  });

  factory AssociateCommitteeMemberModel.fromJson(Map<String, dynamic> json) {
    final tier = json['tier'] as int? ?? 1;
    return AssociateCommitteeMemberModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      position: json['role']?.toString() ?? json['position']?.toString() ?? '',
      photoUrl: json['photo']?.toString() ?? json['photoUrl']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      isHighlighted: tier == 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'position': position,
    'phone': phone,
    'photoUrl': photoUrl,
    'isHighlighted': isHighlighted,
  };
}