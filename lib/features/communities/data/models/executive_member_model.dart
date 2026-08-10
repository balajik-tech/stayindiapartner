import '../../domain/entities/executive_member_entity.dart';

class CoreMemberModel extends CoreMemberEntity {
  const CoreMemberModel({
    required super.id,
    required super.name,
    required super.photoUrl,
  });

  factory CoreMemberModel.fromJson(Map<String, dynamic> json) {
    return CoreMemberModel(
      id: json['id'] as String,
      name: json['name'] as String,
      photoUrl: json['photoUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'photoUrl': photoUrl,
  };
}

class AssociateExecutiveMemberModel extends ExecutiveMemberEntity {
  const AssociateExecutiveMemberModel({
    required super.id,
    required super.name,
    required super.zone,
    required super.photoUrl,
    super.coreMembers = const [],
  });

  factory AssociateExecutiveMemberModel.fromJson(Map<String, dynamic> json) {
    return AssociateExecutiveMemberModel(
      id: json['id'] as String,
      name: json['name'] as String,
      zone: json['zone'] as String,
      photoUrl: json['photoUrl'] as String,
      coreMembers: (json['coreMembers'] as List<dynamic>?)
              ?.map((e) => CoreMemberModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'zone': zone,
    'photoUrl': photoUrl,
    'coreMembers': coreMembers.map((e) => (e as CoreMemberModel).toJson()).toList(),
  };
}
