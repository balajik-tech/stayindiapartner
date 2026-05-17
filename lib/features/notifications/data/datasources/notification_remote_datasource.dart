import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/notification_entity.dart';

abstract class NotificationRemoteDataSource {
  Future<List<NotificationEntity>> getNotifications();
  Future<void> markAllAsRead();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final Dio _dio;

  NotificationRemoteDataSourceImpl(this._dio);

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    final response = await _dio.get(ApiConstants.notifications);
    if (response.statusCode == 200) {
      
      final dynamic responseData = response.data['data'];
      final List results = (responseData is Map)
          ? (responseData['items'] ?? responseData['results'] ?? [])
          : [];
      return results.map((json) => NotificationEntity.fromJson(json)).toList();
    }
    throw Exception('Failed to fetch notifications');
  }

  @override
  Future<void> markAllAsRead() async {
    await _dio.post('${ApiConstants.notifications}/mark-read-all');
  }
}
