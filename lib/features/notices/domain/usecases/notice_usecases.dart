import 'package:stayindia_owner/features/notices/domain/entities/notice.dart';
import 'package:stayindia_owner/features/notices/domain/repositories/notice_repository.dart';

class CreateNoticeUseCase {
  final NoticeRepository repository;
  CreateNoticeUseCase(this.repository);

  Future<void> call({
    required String hostelId,
    required String tenantId,
    required String roomId,
    required String bedNumber,
    required String vacatingDate,
    String? noticeDate,
    String? reason,
  }) {
    return repository.createNotice(
      hostelId: hostelId,
      tenantId: tenantId,
      roomId: roomId,
      bedNumber: bedNumber,
      vacatingDate: vacatingDate,
      noticeDate: noticeDate,
      reason: reason,
    );
  }
}

class GetNoticesUseCase {
  final NoticeRepository repository;
  GetNoticesUseCase(this.repository);

  Future<List<Notice>> call({String? hostelId, String? status}) {
    return repository.getNotices(hostelId: hostelId, status: status);
  }
}

class GetNoticeByIdUseCase {
  final NoticeRepository repository;
  GetNoticeByIdUseCase(this.repository);

  Future<Notice> call(String id) {
    return repository.getNoticeById(id);
  }
}

class UpdateNoticeUseCase {
  final NoticeRepository repository;
  UpdateNoticeUseCase(this.repository);

  Future<void> call(String id, Map<String, dynamic> data) {
    return repository.updateNotice(id, data);
  }
}
