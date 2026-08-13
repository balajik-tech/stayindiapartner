import 'package:equatable/equatable.dart';

class ExecutiveStructureMemberEntity extends Equatable {
  final String id;
  final String name;
  final String photoUrl;
  final String phone;

  const ExecutiveStructureMemberEntity({
    required this.id,
    required this.name,
    this.photoUrl = '',
    required this.phone,
  });

  @override
  List<Object?> get props => [id, name, photoUrl];
}

class ExecutiveStructureLeaderEntity extends Equatable {
  final String id;
  final String name;
  final String photoUrl;
  final String phone;
  final List<ExecutiveStructureMemberEntity> members;

  const ExecutiveStructureLeaderEntity({
    required this.id,
    required this.name,
    this.photoUrl = '',
    required this.members,
    required this.phone
  });

  @override
  List<Object?> get props => [id, name, photoUrl, members];
}
