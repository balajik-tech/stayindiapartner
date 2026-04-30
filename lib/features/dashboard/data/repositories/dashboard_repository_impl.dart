import 'package:stayindia_owner/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:stayindia_owner/features/dashboard/domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/occupancy_summary.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/daily_operations.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/rent_due_details.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/occupancy_status_entity.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remote;

  DashboardRepositoryImpl({required this.remote});

  @override
  Future<DashboardData> getDashboardData(String hostelId) async {
    final results = await Future.wait([
      remote.getOccupancy(hostelId),
      remote.getDailyOperations(hostelId),
      remote.getRentDueDetails(hostelId),
      remote.getOccupancyStatus(hostelId),
    ]);

    return DashboardData(
      occupancy: results[0] as Occupancy,
      dailyOperations: results[1] as DailyOperations,
      rentDueDetails: results[2] as RentDueDetails,
      occupancyStatus: results[3] as OccupancyStatus,
    );
  }

  @override
  Future<RentDueDetails> getRentDueDetails(String hostelId) {
    return remote.getRentDueDetails(hostelId);
  }
}
