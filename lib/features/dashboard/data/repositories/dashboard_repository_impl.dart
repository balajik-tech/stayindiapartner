import 'package:stayindia_owner/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:stayindia_owner/features/dashboard/domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/occupancy_summary.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/daily_operations.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/rent_due_details.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remote;

  DashboardRepositoryImpl({required this.remote});

  @override
  Future<DashboardData> getDashboardData(String hostelId) async {
    
    final results = await Future.wait([
      remote.getOccupancy(hostelId),
      remote.getDailyOperations(hostelId),
    ]);

    return DashboardData(
      occupancy: results[0] as Occupancy,
      dailyOperations: results[1] as DailyOperations,
    );
  }

  @override
  Future<RentDueDetails> getRentDueDetails(String hostelId) {
    return remote.getRentDueDetails(hostelId);
  }
}
