import 'package:equatable/equatable.dart';

/// A member of the IT Wing (technology & digital team).
class ItWingMemberEntity extends Equatable {
  final String id; // e.g. TNIT-ITW-01
  final String name;
  final String role;
  final String photoUrl;
  final String phone;

  const ItWingMemberEntity({
    required this.id,
    required this.name,
    required this.role,
    required this.photoUrl,
    required this.phone
  });

  @override
  List<Object?> get props => [id, name, role, photoUrl];
}