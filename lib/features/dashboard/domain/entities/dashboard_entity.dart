import 'package:equatable/equatable.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/occupancy_summary.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/daily_operations.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/occupancy_status_entity.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/rent_due_details.dart';

class DashboardData extends Equatable {
  final Occupancy occupancy;
  final DailyOperations dailyOperations;
  final OccupancyStatus occupancyStatus;
  final RentDueDetails rentDueDetails;

  const DashboardData({
    required this.occupancy,
    required this.dailyOperations,
    required this.occupancyStatus,
    required this.rentDueDetails,
  });

  @override
  List<Object?> get props => [occupancy, dailyOperations, occupancyStatus, rentDueDetails];
}
