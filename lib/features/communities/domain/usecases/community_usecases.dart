import '../entities/community_entity.dart';
import '../repositories/community_repository.dart';

class GetCommunityDetailsUseCase {
  final CommunityRepository repository;
  GetCommunityDetailsUseCase(this.repository);
  Future<CommunityDetailsEntity> call(String hostelId) => repository.getCommunityDetails(hostelId);
}

class GetCommunityMessagesUseCase {
  final CommunityRepository repository;
  GetCommunityMessagesUseCase(this.repository);
  Future<List<CommunityMessageEntity>> call(
    String hostelId, {
    int limit = 50,
    String? before,
  }) =>
      repository.getMessages(hostelId, limit: limit, before: before);
}

class SendCommunityMessageUseCase {
  final CommunityRepository repository;
  SendCommunityMessageUseCase(this.repository);
  Future<void> call(String hostelId, String text) => repository.sendMessage(hostelId, text);
}

class GetAnnouncementsUseCase {
  final CommunityRepository repository;
  GetAnnouncementsUseCase(this.repository);
  Future<List<AnnouncementEntity>> call(String hostelId) => repository.getAnnouncements(hostelId);
}

class PostAnnouncementUseCase {
  final CommunityRepository repository;
  PostAnnouncementUseCase(this.repository);
  Future<void> call(String hostelId, String title, String content) => 
      repository.postAnnouncement(hostelId, title, content);
}

class GetOwnerDiscussionsUseCase {
  final CommunityRepository repository;
  GetOwnerDiscussionsUseCase(this.repository);
  Future<List<OwnerDiscussionEntity>> call(String hostelId) => repository.getOwnerDiscussions(hostelId);
}

class CreateOwnerDiscussionUseCase {
  final CommunityRepository repository;
  CreateOwnerDiscussionUseCase(this.repository);
  Future<void> call({
    required String title,
    required String description,
    required String type,
    String? hostelId,
  }) => repository.createOwnerDiscussion(
    title: title,
    description: description,
    type: type,
    hostelId: hostelId,
  );
}

class GetJoinedOwnerCommunitiesUseCase {
  final CommunityRepository repository;
  GetJoinedOwnerCommunitiesUseCase(this.repository);
  Future<List<CommunityDetailsEntity>> call() =>
      repository.getJoinedOwnerCommunities();
}

class GetAvailableOwnerCommunitiesUseCase {
  final CommunityRepository repository;
  GetAvailableOwnerCommunitiesUseCase(this.repository);
  Future<List<CommunityDetailsEntity>> call() =>
      repository.getAvailableOwnerCommunities();
}

class JoinOwnerCommunityUseCase {
  final CommunityRepository repository;
  JoinOwnerCommunityUseCase(this.repository);
  Future<void> call(String communityId) =>
      repository.joinOwnerCommunity(communityId);
}

class CreateOwnerCommunityUseCase {
  final CommunityRepository repository;
  CreateOwnerCommunityUseCase(this.repository);
  Future<void> call({
    required String name,
    String? description,
    String? imagePath,
  }) =>
      repository.createOwnerCommunity(
        name: name,
        description: description,
        imagePath: imagePath,
      );
}

class GetPendingJoinRequestsUseCase {
  final CommunityRepository repository;
  GetPendingJoinRequestsUseCase(this.repository);
  Future<List<Map<String, dynamic>>> call() => repository.getPendingJoinRequests();
}

class HandleJoinRequestUseCase {
  final CommunityRepository repository;
  HandleJoinRequestUseCase(this.repository);
  Future<void> call({
    required String communityId,
    required String requesterId,
    required String action,
  }) => repository.handleJoinRequest(
    communityId: communityId,
    requesterId: requesterId,
    action: action,
  );
}

class GetCommunityInfoUseCase {
  final CommunityRepository repository;
  GetCommunityInfoUseCase(this.repository);
  Future<Map<String, dynamic>> call(String communityId) => repository.getCommunityInfo(communityId);
}
