import 'package:equatable/equatable.dart';

class PortMemberEntity extends Equatable {
  final String id;
  final String name;
  final String role;
  final String photoUrl;
  final String phone;

  const PortMemberEntity({
    required this.id,
    required this.name,
    required this.role,
    required this.photoUrl,
    required this.phone
  });

  @override
  List<Object?> get props => [id, name, role, photoUrl];
}
