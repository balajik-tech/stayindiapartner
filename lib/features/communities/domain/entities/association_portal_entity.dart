import 'package:equatable/equatable.dart';

class AssociationPortalEntity extends Equatable {
  final String id;
  final String associationId;
  final String name;
  final String address;
  final String email;
  final String phone;
  final String logo;

  const AssociationPortalEntity({
    required this.id,
    required this.associationId,
    required this.name,
    required this.address,
    required this.email,
    required this.phone,
    required this.logo,
  });

  @override
  List<Object?> get props => [id, associationId, name, address, email, phone, logo];
}
