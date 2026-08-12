import 'package:equatable/equatable.dart';

class ExecutiveStructureMemberEntity extends Equatable {
  final String id;
  final String name;
  final String photoUrl;

  const ExecutiveStructureMemberEntity({
    required this.id,
    required this.name,
    this.photoUrl = '',
  });

  @override
  List<Object?> get props => [id, name, photoUrl];
}

class ExecutiveStructureLeaderEntity extends Equatable {
  final String id;
  final String name;
  final String photoUrl;
  final List<ExecutiveStructureMemberEntity> members;

  const ExecutiveStructureLeaderEntity({
    required this.id,
    required this.name,
    this.photoUrl = '',
    required this.members,
  });

  @override
  List<Object?> get props => [id, name, photoUrl, members];
}
