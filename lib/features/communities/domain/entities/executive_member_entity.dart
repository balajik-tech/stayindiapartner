import 'package:equatable/equatable.dart';

/// A general Executive Member, grouped by zone.
class ExecutiveMemberEntity extends Equatable {
  final String id; // e.g. TNIT-EXE-001
  final String name;
  final String zone;
  final String photoUrl;

  const ExecutiveMemberEntity({
    required this.id,
    required this.name,
    required this.zone,
    required this.photoUrl,
  });

  @override
  List<Object?> get props => [id, name, zone, photoUrl];
}