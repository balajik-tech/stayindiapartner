import '../../domain/entities/property_entity.dart';
import 'bank_account_model.dart';

class PropertyModel extends PropertyEntity {
  const PropertyModel({
    required super.id,
    required super.name,
    required super.location,
    required super.code,
    required super.verificationStatus,
    required super.accounts,
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? json['hostelId'] ?? json['_id']) as String;
    final name = (json['name'] ?? json['hostelName'] ?? '') as String;
    final area = json['area'] as String?;
    final city = json['city'] as String?;
    final location = json['location'] as String? ??
        ((area != null && city != null) ? '$area · $city' : (area ?? city ?? ''));
    final code = (json['code'] ?? json['hostelId'] ?? '') as String;

    return PropertyModel(
      id: id,
      name: name,
      location: location,
      code: code,
      verificationStatus: PropertyVerificationStatus.values.firstWhere(
        (e) => e.name == json['verificationStatus'],
        orElse: () => PropertyVerificationStatus.pending,
      ),
      accounts: (json['accounts'] as List<dynamic>? ?? [])
          .map((a) => BankAccountModel.fromJson(
                a as Map<String, dynamic>,
                defaultPropertyId: id,
              ))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'code': code,
      'verificationStatus': verificationStatus.name,
      'accounts': accounts.map((a) => BankAccountModel.fromEntity(a).toJson()).toList(),
    };
  }
}
