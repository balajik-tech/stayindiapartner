import '../../domain/entities/service_request_entity.dart';
import '../../domain/repositories/request_service_repository.dart';
import '../datasources/request_service_remote_datasource.dart';

class RequestServiceRepositoryImpl implements RequestServiceRepository {
  final RequestServiceRemoteDataSource remoteDataSource;

  RequestServiceRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ServiceRequestEntity> createServiceRequest({
    required String hostelId,
    required String serviceType,
    required String date,
    required String slot,
    String? details,
    List<String> tags = const [],
  }) {
    return remoteDataSource.createServiceRequest(
      hostelId: hostelId,
      serviceType: serviceType,
      date: date,
      slot: slot,
      details: details,
      tags: tags,
    );
  }

  @override
  Future<List<ServiceRequestEntity>> getServiceRequests({
    required String hostelId,
  }) {
    return remoteDataSource.getServiceRequests(hostelId: hostelId);
  }
}
