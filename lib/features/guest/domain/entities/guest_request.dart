import 'package:equatable/equatable.dart';

class GuestRequest extends Equatable {
  final String id;
  final String tenantId;
  final String tenantName;
  final String tenantPhone;
  final String hostelId;
  final String guestName;
  final String mobile;
  final String relationship;
  final String? enteringTime;
  final DateTime startDate;
  final DateTime endDate;
  final int numberOfDays;
  final double dailyRent;
  final double totalAmount;
  final String status;
  final String? rejectionReason;
  final DateTime createdAt;

  const GuestRequest({
    required this.id,
    required this.tenantId,
    required this.tenantName,
    required this.tenantPhone,
    required this.hostelId,
    required this.guestName,
    required this.mobile,
    required this.relationship,
    this.enteringTime,
    required this.startDate,
    required this.endDate,
    required this.numberOfDays,
    required this.dailyRent,
    required this.totalAmount,
    required this.status,
    this.rejectionReason,
    required this.createdAt,
  });

  factory GuestRequest.fromJson(Map<String, dynamic> json) {
    final tenant = json['tenant'] is Map ? json['tenant'] : {};
    return GuestRequest(
      id: json['_id'] ?? json['id'] ?? '',
      tenantId: tenant['_id'] ?? json['tenantId'] ?? '',
      tenantName: tenant['name'] ?? 'Unknown Tenant',
      tenantPhone: tenant['phoneNumber'] ?? '',
      hostelId: json['hostel'] is Map
          ? json['hostel']['_id']
          : (json['hostel'] ?? ''),
      guestName: json['guestName'] ?? '',
      mobile: json['mobile'] ?? '',
      relationship: json['relationship'] ?? '',
      enteringTime: json['enteringTime'],
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      numberOfDays: json['numberOfDays'] ?? 0,
      dailyRent: (json['dailyRent'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'PENDING',
      rejectionReason: json['rejectionReason'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  @override
  List<Object?> get props => [id, status];
}
