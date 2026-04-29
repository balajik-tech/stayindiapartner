import '../entities/dashboard_entity.dart';
import '../entities/rent_due_details.dart';

abstract class DashboardRepository {
  Future<DashboardData> getDashboardData(String hostelId);
  Future<RentDueDetails> getRentDueDetails(String hostelId);
}
