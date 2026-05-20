import '../entities/notification_entity.dart';

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications();
  Future<void> markAllAsRead();
  Future<void> sendBulkMessage({
    required List<String> tenantIds,
    required String title,
    required String message,
  });
}

