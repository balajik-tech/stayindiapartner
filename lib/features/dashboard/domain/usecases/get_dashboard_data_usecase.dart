import '../entities/dashboard_entity.dart';
import '../repositories/dashboard_repository.dart';

class GetDashboardDataUseCase {
  final DashboardRepository repository;

  GetDashboardDataUseCase(this.repository);

  Future<DashboardData> execute(String hostelId) {
    return repository.getDashboardData(hostelId);
  }

  
  Future<DashboardData> call(String hostelId) => execute(hostelId);
}
