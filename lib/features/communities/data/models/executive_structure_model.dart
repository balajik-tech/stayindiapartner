import '../../domain/entities/executive_structure_entity.dart';

class ExecutiveStructureMemberModel extends ExecutiveStructureMemberEntity {
  const ExecutiveStructureMemberModel({
    required super.id,
    required super.name,
    super.photoUrl = '',
    required super.phone
  });

  factory ExecutiveStructureMemberModel.fromJson(Map<String, dynamic> json) {
    return ExecutiveStructureMemberModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      photoUrl: json['photo'] ?? json['photoUrl'] ?? '',
      phone: json['phone'] ?? '',
    );
  }
}

class ExecutiveStructureLeaderModel extends ExecutiveStructureLeaderEntity {
  const ExecutiveStructureLeaderModel({
    required super.id,
    required super.name,
    super.photoUrl = '',
    required List<ExecutiveStructureMemberModel> super.members, required super.phone,
  });

  factory ExecutiveStructureLeaderModel.fromJson(Map<String, dynamic> json) {
    return ExecutiveStructureLeaderModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      photoUrl: json['photo'] ?? json['photoUrl'] ?? '',
      members: (json['members'] as List<dynamic>?)
              ?.map((e) => ExecutiveStructureMemberModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      phone:  json['phone'] ?? '',
    );
  }
}
