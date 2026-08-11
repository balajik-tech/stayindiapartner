import 'package:equatable/equatable.dart';

class PortMemberEntity extends Equatable {
  final String id;
  final String name;
  final String role;
  final String photoUrl;

  const PortMemberEntity({
    required this.id,
    required this.name,
    required this.role,
    required this.photoUrl,
  });

  @override
  List<Object?> get props => [id, name, role, photoUrl];
}
