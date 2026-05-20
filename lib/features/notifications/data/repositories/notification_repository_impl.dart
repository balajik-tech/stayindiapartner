import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<NotificationEntity>> getNotifications() async {
    return await remoteDataSource.getNotifications();
  }

  @override
  Future<void> markAllAsRead() async {
    await remoteDataSource.markAllAsRead();
  }

  @override
  Future<void> sendBulkMessage({
    required List<String> tenantIds,
    required String title,
    required String message,
  }) async {
    await remoteDataSource.sendBulkMessage(
      tenantIds: tenantIds,
      title: title,
      message: message,
    );
  }
}

