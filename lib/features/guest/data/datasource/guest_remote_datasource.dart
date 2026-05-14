import 'package:dio/dio.dart';
import '../../domain/entities/guest_request.dart';

abstract class GuestRemoteDataSource {
  Future<List<GuestRequest>> getHostelGuestRequests(String hostelId);
  Future<GuestRequest> updateGuestRequestStatus(String requestId, String status, {String? rejectionReason});
}

class GuestRemoteDataSourceImpl implements GuestRemoteDataSource {
  final Dio dio;

  GuestRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<GuestRequest>> getHostelGuestRequests(String hostelId) async {
    final response = await dio.get('/guests/hostel/$hostelId');

    if (response.statusCode == 200) {
      final List data = response.data['data'];
      return data.map((json) => GuestRequest.fromJson(json)).toList();
    }
    throw Exception('Failed to fetch guest requests');
  }

  @override
  Future<GuestRequest> updateGuestRequestStatus(String requestId, String status, {String? rejectionReason}) async {
    final Map<String, dynamic> data = {
      'status': status,
    };
    if (rejectionReason != null) {
      data['rejectionReason'] = rejectionReason;
    }
    
    final response = await dio.patch('/guests/$requestId/status', data: data);

    if (response.statusCode == 200) {
      return GuestRequest.fromJson(response.data['data']);
    }
    throw Exception('Failed to update guest request status');
  }
}
