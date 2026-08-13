import '../../domain/entities/port_member_entity.dart';

class AssociatePortMemberModel extends PortMemberEntity {
  const AssociatePortMemberModel({
    required super.id,
    required super.name,
    required super.role,
    required super.photoUrl,
    required super.phone
  });

  factory AssociatePortMemberModel.fromJson(Map<String, dynamic> json) {
    return AssociatePortMemberModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      photoUrl: json['photo'] ?? json['photoUrl'] ?? '',
      phone:json['phone'] ?? '',
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
