import 'package:equatable/equatable.dart';

class AssociationMembershipEntity extends Equatable {
  final String id;
  final String status;
  final String? applicationReference;
  final DateTime? submittedAt;
  final DateTime? approvedAt;
  final double? totalFee;
  final String? membershipId;
  final Map<String, dynamic>? timeline;
  final List<MembershipPropertyEntity> properties;

  const AssociationMembershipEntity({
    required this.id,
    required this.status,
    this.applicationReference,
    this.submittedAt,
    this.approvedAt,
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
