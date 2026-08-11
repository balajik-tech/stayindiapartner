import '../../domain/entities/association_portal_entity.dart';

class AssociationPortalModel extends AssociationPortalEntity {
  const AssociationPortalModel({
    required super.id,
    required super.associationId,
    required super.name,
    required super.address,
    required super.email,
    required super.phone,
    required super.logo,
  });

  factory AssociationPortalModel.fromJson(Map<String, dynamic> json) {
    return AssociationPortalModel(
      id: json['_id'] ?? '',
      associationId: json['associationId'] ?? '',
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      logo: json['logo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'associationId': associationId,
      'name': name,
      'address': address,
      'email': email,
      'phone': phone,
      'logo': logo,
    };
  }
}
