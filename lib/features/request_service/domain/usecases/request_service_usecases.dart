import '../entities/service_request_entity.dart';
import '../repositories/request_service_repository.dart';

class CreateServiceRequestUseCase {
  final RequestServiceRepository repository;

  CreateServiceRequestUseCase(this.repository);

  Future<ServiceRequestEntity> call({
    required String hostelId,
    required String serviceType,
    required String date,
    required String slot,
    String? details,
    List<String> tags = const [],
  }) {
    return repository.createServiceRequest(
      hostelId: hostelId,
      serviceType: serviceType,
      date: date,
      slot: slot,
      details: details,
      tags: tags,
    );
  }
}

class GetServiceRequestsUseCase {
  final RequestServiceRepository repository;

  GetServiceRequestsUseCase(this.repository);

  Future<List<ServiceRequestEntity>> call({required String hostelId}) {
    return repository.getServiceRequests(hostelId: hostelId);
  }
}
