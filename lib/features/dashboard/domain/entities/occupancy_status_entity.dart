import 'package:equatable/equatable.dart';

class OccupancyStatus extends Equatable {
  final int total;
  final int inside;
  final int outside;
  final int unknown;

  const OccupancyStatus({
    required this.total,
    required this.inside,
    required this.outside,
    required this.unknown,
  });

  factory OccupancyStatus.empty() {
    return const OccupancyStatus(total: 0, inside: 0, outside: 0, unknown: 0);
  }

  @override
  List<Object?> get props => [total, inside, outside, unknown];
}
