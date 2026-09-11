import 'package:equatable/equatable.dart';

class ServiceRequestEntity extends Equatable {
  final String id;
  final String hostelId;
  final String serviceType;
  final String date;
  final String slot;
  final String? details;
  final List<String> tags;
  final String status;
  final DateTime createdAt;

  const ServiceRequestEntity({
    required this.id,
    required this.hostelId,
    required this.serviceType,
    required this.date,
    required this.slot,
    this.details,
    this.tags = const [],
    required this.status,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        hostelId,
        serviceType,
        date,
        slot,
        details,
        tags,
        status,
        createdAt,
      ];
}
