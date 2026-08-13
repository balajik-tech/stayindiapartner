import '../../domain/entities/it_wing_member_entity.dart';

class AssociateItWingMemberModel extends ItWingMemberEntity {
  const AssociateItWingMemberModel({
    required super.id,
    required super.name,
    required super.role,
    required super.photoUrl,
    required super.phone
  });

  factory AssociateItWingMemberModel.fromJson(Map<String, dynamic> json) {
    return AssociateItWingMemberModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      photoUrl: json['photo'] ?? json['photoUrl'] ?? '',
      phone: json['phone'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role,
    'photoUrl': photoUrl,
    'phone':phone
  };
}