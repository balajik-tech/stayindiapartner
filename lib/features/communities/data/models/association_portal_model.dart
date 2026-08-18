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
    String addressStr = '';
    final rawAddress = json['address'];
    if (rawAddress is String) {
      addressStr = rawAddress;
    } else if (rawAddress is Map<String, dynamic>) {
      final line1 = rawAddress['line1']?.toString() ?? '';
      final line2 = rawAddress['line2']?.toString() ?? '';
      final city = rawAddress['city']?.toString() ?? '';
      final state = rawAddress['state']?.toString() ?? '';
      final pincode = rawAddress['pincode']?.toString() ?? '';

      final parts = [
        if (line1.isNotEmpty) line1,
        if (line2.isNotEmpty) line2,
        if (city.isNotEmpty) city,
        if (state.isNotEmpty) state,
        if (pincode.isNotEmpty) pincode,
      ];
      addressStr = parts.join(', ');
    } else if (rawAddress != null) {
      addressStr = rawAddress.toString();
    }

    return AssociationPortalModel(
      id: json['_id']?.toString() ?? '',
      associationId: json['associationId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: addressStr,
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      logo: json['logo']?.toString() ?? '',
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
