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
    return PropertyModel(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      code: json['code'] as String,
      verificationStatus: PropertyVerificationStatus.values.firstWhere(
        (e) => e.name == json['verificationStatus'],
        orElse: () => PropertyVerificationStatus.pending,
      ),
      accounts: (json['accounts'] as List<dynamic>? ?? [])
          .map((a) => BankAccountModel.fromJson(a as Map<String, dynamic>))
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
