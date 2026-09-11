import '../entities/service_request_entity.dart';

abstract class RequestServiceRepository {
  Future<ServiceRequestEntity> createServiceRequest({
    required String hostelId,
    required String serviceType,
    required String date,
    required String slot,
    String? details,
    List<String> tags = const [],
  });

  Future<List<ServiceRequestEntity>> getServiceRequests({
    required String hostelId,
  });
}
