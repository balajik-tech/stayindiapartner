import '../../domain/entities/service_request_entity.dart';

class ServiceRequestModel extends ServiceRequestEntity {
  const ServiceRequestModel({
    required super.id,
    required super.hostelId,
    required super.serviceType,
    required super.date,
    required super.slot,
    super.details,
    super.tags,
    required super.status,
    required super.createdAt,
  });

  factory ServiceRequestModel.fromJson(Map<String, dynamic> json) {
    return ServiceRequestModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      hostelId: json['hostelId']?.toString() ?? json['hostel']?.toString() ?? '',
      serviceType: json['serviceType']?.toString() ?? json['title']?.toString() ?? 'Service Request',
      date: json['date']?.toString() ?? '',
      slot: json['slot']?.toString() ?? 'Morning',
      details: json['details']?.toString() ?? json['description']?.toString(),
      tags: json['tags'] != null ? List<String>.from(json['tags']) : const [],
      status: json['status']?.toString() ?? 'PENDING',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hostelId': hostelId,
      'serviceType': serviceType,
      'date': date,
      'slot': slot,
      'details': details,
      'tags': tags,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
