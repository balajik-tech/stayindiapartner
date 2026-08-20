import 'package:equatable/equatable.dart';

class AssociationMembershipEntity extends Equatable {
  final String id;
  final String status;
  final String? applicationReference;
  final DateTime? submittedAt;
  final DateTime? validUntil;
  final DateTime? approvedAt;
  final DateTime? expiredAt;
  final String? phone;
  final double? totalFee;
  final String? membershipId;
  final Map<String, dynamic>? timeline;
  final List<MembershipPropertyEntity> properties;

  const AssociationMembershipEntity({
    required this.id,
    required this.status,
    this.applicationReference,
    this.submittedAt,
    this.validUntil,
    this.phone,
    this.approvedAt,
    this.expiredAt,
    this.totalFee,
    this.membershipId,
    this.timeline,
    required this.properties,
  });

  @override
  List<Object?> get props => [
        id,
        status,
        applicationReference,
        submittedAt,
        approvedAt,
        expiredAt,
        phone,
        validUntil,
        totalFee,
        membershipId,
        timeline,
        properties,
      ];
}

class MembershipPropertyEntity extends Equatable {
  final String id;
  final String name;
  final String address;
  final String city;
  final String? hostelType;
  final String? propertyTag;
  final String location;
  final String type;
  final bool isActive;

  const MembershipPropertyEntity({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    this.hostelType,
    this.propertyTag,
    required this.location,
    required this.type,
    required this.isActive,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        city,
        hostelType,
        propertyTag,
        location,
        type,
        isActive,
      ];
}

class MembershipPaymentDetailsEntity extends Equatable {
  final String applicationReference;
  final int properties;
  final int validForMonths;
  final double amount;
  final double totalFee;
  final String currency;
  final bool collectViaApp;
  final String? accountHolder;
  final String? accountNumberLast4;
  final String? ifsc;
  final String? bankName;
  final String? upi;

  const MembershipPaymentDetailsEntity({
    required this.applicationReference,
    required this.properties,
    required this.validForMonths,
    required this.amount,
    required this.totalFee,
    required this.currency,
    required this.collectViaApp,
    this.accountHolder,
    this.accountNumberLast4,
    this.ifsc,
    this.bankName,
    this.upi,
  });

  @override
  List<Object?> get props => [
        applicationReference,
        properties,
        validForMonths,
        amount,
        totalFee,
        currency,
        collectViaApp,
        accountHolder,
        accountNumberLast4,
        ifsc,
        bankName,
        upi,
      ];
}
