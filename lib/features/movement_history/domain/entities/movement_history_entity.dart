import 'package:equatable/equatable.dart';

class MovementHistoryEntity extends Equatable {
  final String id;
  final String userId;
  final String propertyId;
  final String action;
  final DateTime timestamp;
  final String? source;

  const MovementHistoryEntity({
    required this.id,
    required this.userId,
    required this.propertyId,
    required this.action,
    required this.timestamp,
    this.source,
  });

  factory MovementHistoryEntity.fromJson(Map<String, dynamic> json) {
    return MovementHistoryEntity(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      propertyId: json['propertyId'] ?? '',
      action: json['action'] ?? json['status'] ?? 'UNKNOWN',
      timestamp: json['timestamp'] != null ? DateTime.parse(json['timestamp']).toLocal() : DateTime.now(),
      source: json['source'],
    );
  }

  @override
  List<Object?> get props => [id, userId, propertyId, action, timestamp, source];
}
