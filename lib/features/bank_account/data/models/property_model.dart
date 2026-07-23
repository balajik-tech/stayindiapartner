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
    final hostelJson = (json['hostel'] as Map<String, dynamic>?) ?? json;
    final id = (hostelJson['id'] ?? hostelJson['hostelId'] ?? hostelJson['_id']) as String;
    final name = (hostelJson['name'] ?? hostelJson['hostelName'] ?? '') as String;
    final area = hostelJson['area'] as String?;
    final city = hostelJson['city'] as String?;
    final location = hostelJson['location'] as String? ??
        ((area != null && city != null) ? '$area · $city' : (area ?? city ?? ''));
    final code = (hostelJson['code'] ?? hostelJson['hostelId'] ?? '') as String;

    final accountData = (json['bankAccounts'] as List<dynamic>?) ??
        (hostelJson['bankAccounts'] as List<dynamic>?) ??
        [];

    final rawVerification = hostelJson['verificationStatus'] ?? hostelJson['isVerified'];
    final verificationStatus = rawVerification is bool
        ? (rawVerification ? PropertyVerificationStatus.verified : PropertyVerificationStatus.pending)
        : PropertyVerificationStatus.values.firstWhere(
            (e) => e.name == rawVerification,
            orElse: () => PropertyVerificationStatus.pending,
          );

    return PropertyModel(
      id: id,
      name: name,
      location: location,
      code: code,
      verificationStatus: verificationStatus,
      accounts: accountData
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
      'bankAccounts': accounts.map((a) => BankAccountModel.fromEntity(a).toJson()).toList(),
    };
  }
}
