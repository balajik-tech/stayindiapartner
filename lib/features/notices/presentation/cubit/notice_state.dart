part of 'notice_cubit.dart';

abstract class NoticeState extends Equatable {
  const NoticeState();
  @override
  List<Object?> get props => [];
}

class NoticeInitial extends NoticeState {}

class NoticeSubmitting extends NoticeState {}

class NoticeSuccess extends NoticeState {}

class NoticeLoading extends NoticeState {}

class NoticesLoaded extends NoticeState {
  final List<Notice> notices;
  final List<AnnouncementEntity> announcements;
  const NoticesLoaded({required this.notices, this.announcements = const []});
  @override
  List<Object?> get props => [notices, announcements];
}

class NoticeUpdating extends NoticeState {}

class NoticeUpdateSuccess extends NoticeState {}

class NoticeLoadError extends NoticeState {
  final String message;
  const NoticeLoadError({required this.message});
  @override
  List<Object?> get props => [message];
}

class NoticeSubmitError extends NoticeState {
  final String message;
  const NoticeSubmitError({required this.message});
  @override
  List<Object?> get props => [message];
}

class NoticeUpdateError extends NoticeState {
  final String message;
  const NoticeUpdateError({required this.message});
  @override
  List<Object?> get props => [message];
}
