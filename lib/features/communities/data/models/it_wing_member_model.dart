import '../../domain/entities/it_wing_member_entity.dart';

class AssociateItWingMemberModel extends ItWingMemberEntity {
  const AssociateItWingMemberModel({
    required super.id,
    required super.name,
    required super.role,
    required super.photoUrl,
  });

  factory AssociateItWingMemberModel.fromJson(Map<String, dynamic> json) {
    return AssociateItWingMemberModel(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      photoUrl: json['photoUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role,
    'photoUrl': photoUrl,
  };
}