import 'package:equatable/equatable.dart';

class CoreMemberEntity extends Equatable {
  final String id;
  final String name;
  final String photoUrl;

  const CoreMemberEntity({
    required this.id,
    required this.name,
    required this.photoUrl,
  });

  @override
  List<Object?> get props => [id, name, photoUrl];
}

/// A general Executive Member, grouped by zone.
class ExecutiveMemberEntity extends Equatable {
  final String id; // e.g. TNIT-EXE-001
  final String name;
  final String zone;
  final String photoUrl;
  final String role;
  final String phone;
  final int tier;
  final bool isHighlighted;
  final List<CoreMemberEntity> coreMembers;

  const ExecutiveMemberEntity({
    required this.id,
    required this.name,
    required this.zone,
    required this.photoUrl,
    this.role = '',
    this.phone = '',
    this.tier = 2,
    this.isHighlighted = false,
    this.coreMembers = const [],
  });

  @override
  List<Object?> get props =>
      [id, name, zone, photoUrl, role, phone, tier, isHighlighted, coreMembers];
}
