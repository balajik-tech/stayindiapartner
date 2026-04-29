import 'package:stayindia_owner/features/dashboard/domain/entities/rent_due_details.dart';
import 'package:stayindia_owner/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetRentDueDetailsUseCase {
  final DashboardRepository repository;

  GetRentDueDetailsUseCase({required this.repository});

  Future<RentDueDetails> call(String hostelId) {
    return repository.getRentDueDetails(hostelId);
  }
}
