import '../../../../core/error/app_exceptions.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<NotificationEntity> notifications;
  final int unreadCount;
  const NotificationLoaded(this.notifications, {this.unreadCount = 0});
  @override
  List<Object?> get props => [notifications, unreadCount];
}

class NotificationError extends NotificationState {
  final String message;
  const NotificationError(this.message);
  @override
  List<Object?> get props => [message];
}

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository repository;

  NotificationCubit({required this.repository}) : super(NotificationInitial());

  Future<void> fetchNotifications() async {
    emit(NotificationLoading());
    try {
      final data = await repository.getNotifications();
      emit(NotificationLoaded(data.notifications, unreadCount: data.unreadCount));
    } catch (e) {
      emit(NotificationError(GlobalErrorMapper.map(e).message));
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await repository.markAllAsRead();
      fetchNotifications();
    } catch (e) {
    }
  }
}
