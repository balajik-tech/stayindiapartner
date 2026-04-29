import 'package:equatable/equatable.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/occupancy_summary.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/daily_operations.dart';

class DashboardData extends Equatable {
  final Occupancy occupancy;
  final DailyOperations dailyOperations;

  const DashboardData({
    required this.occupancy,
    required this.dailyOperations,
  });

  @override
  List<Object?> get props => [occupancy, dailyOperations];
}
