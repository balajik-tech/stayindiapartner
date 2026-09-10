import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../domain/entities/notification_entity.dart';

abstract class NotificationRemoteDataSource {
  Future<NotificationData> getNotifications();
  Future<void> markAllAsRead();
  Future<void> sendBulkMessage({
    required List<String> tenantIds,
    required String title,
    required String message,
  });
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final Dio _dio;

  NotificationRemoteDataSourceImpl(this._dio);

  @override
  Future<NotificationData> getNotifications() async {
    final response = await _dio.get(
      ApiConstants.notifications,
      queryParameters: {'appType': 'OWNER_APP'},
    );
    if (response.statusCode == 200) {
      final dynamic responseData = response.data['data'];
      final List results = (responseData is Map)
          ? (responseData['items'] ?? responseData['results'] ?? [])
          : [];
      final int unreadCount = (responseData is Map)
          ? (responseData['unreadCount'] ?? 0)
          : 0;
      
      final notifications = results.map((json) => NotificationEntity.fromJson(json)).toList();
      return NotificationData(
        notifications: notifications,
        unreadCount: unreadCount,
      );
    }
    throw Exception('Failed to fetch notifications');
  }

  @override
  Future<void> markAllAsRead() async {
    await _dio.post(
      '${ApiConstants.notifications}/mark-read-all',
      queryParameters: {'appType': 'OWNER_APP'},
    );
  }

  @override
  Future<void> sendBulkMessage({
    required List<String> tenantIds,
    required String title,
    required String message,
  }) async {
    final response = await _dio.post(
      '${ApiConstants.notifications}/bulk-message',
      data: {
        'tenantIds': tenantIds,
        'title': title,
        'message': message,
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to send bulk notifications');
    }
  }
}

