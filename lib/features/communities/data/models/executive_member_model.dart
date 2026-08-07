import '../../domain/entities/executive_member_entity.dart';

class AssociateExecutiveMemberModel extends ExecutiveMemberEntity {
  const AssociateExecutiveMemberModel({
    required super.id,
    required super.name,
    required super.zone,
    required super.photoUrl,
  });

  factory AssociateExecutiveMemberModel.fromJson(Map<String, dynamic> json) {
    return AssociateExecutiveMemberModel(
      id: json['id'] as String,
      name: json['name'] as String,
      zone: json['zone'] as String,
      photoUrl: json['photoUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'zone': zone,
    'photoUrl': photoUrl,
  };
}