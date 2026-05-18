import 'package:equatable/equatable.dart';

class OfferEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? image;
  final String? code;
  final String type;
  final double value;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isActive;
  final String? createdBy;
  final String? hostelId;
  final String? hostelName;

  const OfferEntity({
    required this.id,
    required this.title,
    required this.description,
    this.image,
    this.code,
    required this.type,
    required this.value,
    required this.startDate,
    this.endDate,
    required this.isActive,
    this.createdBy,
    this.hostelId,
    this.hostelName,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    image,
    code,
    type,
    value,
    startDate,
    endDate,
    isActive,
    createdBy,
    hostelId,
    hostelName,
  ];

  factory OfferEntity.fromJson(Map<String, dynamic> json) {
    String? hId;
    String? hName;
    if (json['hostel'] != null) {
      if (json['hostel'] is Map) {
        hId = json['hostel']['_id'];
        hName = json['hostel']['name'];
      } else {
        hId = json['hostel'].toString();
      }
    }

    return OfferEntity(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'],
      code: json['code'],
      type: json['type'] ?? 'PROMOTIONAL',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      isActive: json['isActive'] ?? true,
      createdBy: json['createdBy']?.toString(),
      hostelId: hId,
      hostelName: hName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      if (image != null) 'image': image,
      if (code != null) 'code': code,
      'type': type,
      'value': value,
      'startDate': startDate.toIso8601String(),
      if (endDate != null) 'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      if (hostelId != null) 'hostel': hostelId,
    };
  }
}
