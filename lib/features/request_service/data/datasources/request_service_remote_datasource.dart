import 'package:dio/dio.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/core/utils/logger.dart';
import '../models/service_request_model.dart';

abstract class RequestServiceRemoteDataSource {
  Future<ServiceRequestModel> createServiceRequest({
    required String hostelId,
    required String serviceType,
    required String date,
    required String slot,
    String? details,
    List<String> tags = const [],
  });

  Future<List<ServiceRequestModel>> getServiceRequests({
    required String hostelId,
  });
}

class RequestServiceRemoteDataSourceImpl implements RequestServiceRemoteDataSource {
  final Dio dio;

  RequestServiceRemoteDataSourceImpl({required this.dio});

  @override
  Future<ServiceRequestModel> createServiceRequest({
    required String hostelId,
    required String serviceType,
    required String date,
    required String slot,
    String? details,
    List<String> tags = const [],
  }) async {
    try {
      final payload = {
        'hostelId': hostelId,
        'title': '$serviceType - $slot ($date)',
        'description': details ?? serviceType,
        'serviceType': serviceType,
        'date': date,
        'slot': slot,
        'tags': tags,
        'status': 'PENDING',
      };

      final response = await dio.post(
        '${ApiConstants.effectiveBaseUrl}/maintenance',
        data: payload,
      );

      final data = response.data;
      if (data is Map && data['data'] != null) {
        return ServiceRequestModel.fromJson(Map<String, dynamic>.from(data['data']));
      }
      return ServiceRequestModel.fromJson(payload);
    } catch (e) {
      AppLogger.error('Failed to create service request: $e');
      // Return optimistic model on network offline/fallback
      return ServiceRequestModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        hostelId: hostelId,
        serviceType: serviceType,
        date: date,
        slot: slot,
        details: details,
        tags: tags,
        status: 'PENDING',
        createdAt: DateTime.now(),
      );
    }
  }

  @override
  Future<List<ServiceRequestModel>> getServiceRequests({
    required String hostelId,
  }) async {
    try {
      final response = await dio.get(
        '${ApiConstants.effectiveBaseUrl}/maintenance',
        queryParameters: {'hostelId': hostelId},
      );

      final data = response.data;
      if (data is Map && data['data'] != null && data['data']['issues'] is List) {
        final List list = data['data']['issues'];
        return list
            .map((item) => ServiceRequestModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
      return const [];
    } catch (e) {
      AppLogger.error('Failed to get service requests: $e');
      return const [];
    }
  }
}
