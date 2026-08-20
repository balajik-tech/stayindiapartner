import '../../domain/entities/association_membership_entity.dart';

class AssociationMembershipModel extends AssociationMembershipEntity {
  const AssociationMembershipModel({
    required super.id,
    required super.status,
    super.applicationReference,
    super.submittedAt,
    super.approvedAt,
    super.expiredAt,
    super.validUntil,
    super.totalFee,
    super.membershipId,
    super.whatsappLink,
    super.timeline,
    required super.properties,
  });

  factory AssociationMembershipModel.fromJson(Map<String, dynamic> json) {
    return AssociationMembershipModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      status: (json['status'] ?? '').toString().toUpperCase(),
      applicationReference: json['applicationReference']?.toString(),
      submittedAt: json['submittedAt'] != null
          ? DateTime.tryParse(json['submittedAt'].toString())
          : null,
      approvedAt: json['approvedAt'] != null
          ? DateTime.tryParse(json['approvedAt'].toString())
          : null,
      expiredAt: json['expiredAt'] != null
          ? DateTime.tryParse(json['expiredAt'].toString())
          : null,
      validUntil: json['validUntil'] != null
          ? DateTime.tryParse(json['validUntil'].toString())
          : null,
      totalFee: double.tryParse(
          (json['totalFee'] ?? json['fee'] ?? '0').toString()),
      membershipId: json['membershipId']?.toString() ??
          (json['status'] == 'ACTIVE' && json['id'] != null
              ? json['id'].toString()
              : null),
      whatsappLink: json['whatsappLink']?.toString() ?? null,
      timeline: json['timeline'] is Map ? Map<String, dynamic>.from(json['timeline'] as Map) : null,
      properties: (json['properties'] as List? ?? [])
          .map((e) => MembershipPropertyModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class MembershipPropertyModel extends MembershipPropertyEntity {
  const MembershipPropertyModel({
    required super.id,
    required super.name,
    required super.address,
    required super.city,
    super.hostelType,
    super.propertyTag,
    required super.location,
    required super.type,
    required super.isActive,
  });

  factory MembershipPropertyModel.fromJson(Map<String, dynamic> json) {
    final address = json['address']?.toString().trim() ?? '';
    final city = json['city']?.toString().trim() ?? '';
    final locationParts = [
      if (address.isNotEmpty) address,
      if (city.isNotEmpty) city,
    ];
    final location = locationParts.isNotEmpty ? locationParts.join(', ') : 'Chennai';

    final hostelType = json['hostel_type']?.toString();
    final propertyTag = json['propertyTag']?.toString();

    return MembershipPropertyModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      address: address,
      city: city,
      hostelType: hostelType,
      propertyTag: propertyTag,
      location: location,
      type: _formatPropertyType(hostelType, propertyTag),
      isActive: json['isActive'] ?? true,
    );
  }

  static String _formatPropertyType(String? hostelType, String? propertyTag) {
    final typeStr = (hostelType ?? '').toLowerCase().trim();
    if (typeStr == 'men' || typeStr == 'boys' || typeStr == 'male') {
      return "MEN'S HOSTEL";
    } else if (typeStr == 'women' || typeStr == 'girls' || typeStr == 'female') {
      return "WORKING WOMEN'S HOSTEL";
    } else if (typeStr == 'co-living' || typeStr == 'coliving') {
      return "CO-LIVING PG";
    } else if (typeStr == 'students' || typeStr == 'student') {
      return "STUDENTS' PG";
    }
    if (propertyTag != null && propertyTag.trim().isNotEmpty) {
      final tagStr = propertyTag.trim().toUpperCase();
      if (tagStr == 'BOYS' || tagStr == 'MEN') return "MEN'S HOSTEL";
      if (tagStr == 'GIRLS' || tagStr == 'WOMEN') return "WORKING WOMEN'S HOSTEL";
      if (tagStr == 'PG') return "PG HOSTEL";
      return tagStr;
    }
    return "HOSTEL";
  }
}

class MembershipPaymentDetailsModel extends MembershipPaymentDetailsEntity {
  const MembershipPaymentDetailsModel({
    required super.applicationReference,
    required super.properties,
    required super.validForMonths,
    required super.amount,
    required super.totalFee,
    required super.currency,
    required super.collectViaApp,
    super.accountHolder,
    super.accountNumberLast4,
    super.ifsc,
    super.bankName,
    super.upi,
  });

  factory MembershipPaymentDetailsModel.fromJson(Map<String, dynamic> json) {
    return MembershipPaymentDetailsModel(
      applicationReference: json['applicationReference']?.toString() ?? '',
      properties: json['properties'] is int ? json['properties'] : int.tryParse(json['properties']?.toString() ?? '0') ?? 0,
      validForMonths: json['validForMonths'] is int ? json['validForMonths'] : int.tryParse(json['validForMonths']?.toString() ?? '0') ?? 0,
      amount: double.tryParse(json['amount']?.toString() ?? '0') ?? 0.0,
      currency: json['currency']?.toString() ?? 'INR',
      collectViaApp: json['collectViaApp'] == true,
      accountHolder: json['accountHolder']?.toString(),
      accountNumberLast4: json['accountNumberLast4']?.toString(),
      ifsc: json['ifsc']?.toString(),
      bankName: json['bankName']?.toString(),
      upi: json['upi']?.toString(),
      totalFee: double.tryParse(json['totalFee']?.toString() ?? json['amount']?.toString() ?? '0') ?? 0.0,
    );
  }
}
