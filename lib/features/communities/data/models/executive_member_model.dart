import '../../domain/entities/executive_member_entity.dart';

class CoreMemberModel extends CoreMemberEntity {
  const CoreMemberModel({
    required super.id,
    required super.name,
    required super.photoUrl,
  });

  factory CoreMemberModel.fromJson(Map<String, dynamic> json) {
    return CoreMemberModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      photoUrl: json['photo'] ?? json['photoUrl'] ?? '',
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
    super.role = '',
    super.phone = '',
    super.tier = 2,
    super.isHighlighted = false,
    super.coreMembers = const [],
  });

  factory AssociateExecutiveMemberModel.fromJson(Map<String, dynamic> json) {
    final tier = json['tier'] as int? ?? 2;
    return AssociateExecutiveMemberModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      zone: json['unit'] ?? json['zone'] ?? '',
      photoUrl: json['photo'] ?? json['photoUrl'] ?? '',
      role: json['role'] ?? '',
      phone: json['phone']?.toString() ?? '',
      tier: tier,
      isHighlighted: tier <= 1,
      coreMembers: (json['props'] as List<dynamic>?)
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
    'role': role,
    'phone': phone,
    'tier': tier,
    'isHighlighted': isHighlighted,
    'coreMembers': coreMembers.map((e) => (e as CoreMemberModel).toJson()).toList(),
  };
}
