import '../../domain/entities/occupancy_status_entity.dart';

class OccupancyStatusModel extends OccupancyStatus {
  const OccupancyStatusModel({
    required super.total,
    required super.inside,
    required super.outside,
    required super.unknown,
  });

  factory OccupancyStatusModel.fromJson(Map<String, dynamic> json) {
    return OccupancyStatusModel(
      total: json['total'] ?? 0,
      inside: json['inside'] ?? 0,
      outside: json['outside'] ?? 0,
      unknown: json['unknown'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'inside': inside,
      'outside': outside,
      'unknown': unknown,
    };
  }
}
