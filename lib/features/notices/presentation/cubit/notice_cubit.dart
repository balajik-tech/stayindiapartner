import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stayindia_owner/features/notices/domain/entities/notice.dart';
import 'package:stayindia_owner/features/notices/domain/usecases/notice_usecases.dart';
import 'package:stayindia_owner/features/communities/domain/usecases/community_usecases.dart';
import 'package:stayindia_owner/features/communities/domain/entities/community_entity.dart';
import 'package:stayindia_owner/core/utils/error_helper.dart';

part 'notice_state.dart';

class NoticeCubit extends Cubit<NoticeState> {
  final CreateNoticeUseCase _createNotice;
  final GetNoticesUseCase _getNotices;
  final GetNoticeByIdUseCase _getNoticeById;
  final UpdateNoticeUseCase _updateNotice;
  final PostAnnouncementUseCase _postAnnouncement;
  final GetAnnouncementsUseCase _getAnnouncements;

  NoticeCubit({
    required CreateNoticeUseCase createNoticeUseCase,
    required GetNoticesUseCase getNoticesUseCase,
    required GetNoticeByIdUseCase getNoticeByIdUseCase,
    required UpdateNoticeUseCase updateNoticeUseCase,
    required PostAnnouncementUseCase postAnnouncementUseCase,
    required GetAnnouncementsUseCase getAnnouncementsUseCase,
  })  : _createNotice = createNoticeUseCase,
        _getNotices = getNoticesUseCase,
        _getNoticeById = getNoticeByIdUseCase,
        _updateNotice = updateNoticeUseCase,
        _postAnnouncement = postAnnouncementUseCase,
        _getAnnouncements = getAnnouncementsUseCase,
        super(NoticeInitial());

  Future<void> postAnnouncement({
    required String hostelId,
    required String title,
    required String content,
  }) async {
    emit(NoticeSubmitting());
    try {
      await _postAnnouncement(hostelId, title, content);
      emit(NoticeSuccess());
    } catch (e) {
      emit(NoticeSubmitError(message: ErrorHelper.toFriendlyMessage(e)));
    }
  }

  Future<void> createNotice({
    required String hostelId,
    required String tenantId,
    required String roomId,
    required String bedNumber,
    required String vacatingDate,
    String? reason,
  }) async {
    emit(NoticeSubmitting());
    try {
      await _createNotice(
        hostelId: hostelId,
        tenantId: tenantId,
        roomId: roomId,
        bedNumber: bedNumber,
        vacatingDate: vacatingDate,
        reason: reason,
      );
      emit(NoticeSuccess());
    } catch (e) {
      emit(NoticeSubmitError(message: ErrorHelper.toFriendlyMessage(e)));
    }
  }

  Future<void> loadNotices({String? hostelId, String? status}) async {
    emit(NoticeLoading());
    try {
      final notices = await _getNotices(hostelId: hostelId, status: status);
      List<AnnouncementEntity> announcements = [];
      if (hostelId != null) {
        announcements = await _getAnnouncements(hostelId);
      }
      emit(NoticesLoaded(notices: notices, announcements: announcements));
    } catch (e) {
      emit(NoticeLoadError(message: ErrorHelper.toFriendlyMessage(e)));
    }
  }

  Future<void> updateNotice(String id, Map<String, dynamic> data, {String? hostelId}) async {
    emit(NoticeUpdating());
    try {
      await _updateNotice(id, data);
      emit(NoticeUpdateSuccess());
      if (hostelId != null) {
        await loadNotices(hostelId: hostelId);
      }
    } catch (e) {
      emit(NoticeUpdateError(message: ErrorHelper.toFriendlyMessage(e)));
    }
  }

  Future<void> loadNoticeById(String id) async {
    try {
      await _getNoticeById(id);
    } catch (e) {
      emit(NoticeLoadError(message: ErrorHelper.toFriendlyMessage(e)));
    }
  }
}
