import '../entities/community_entity.dart';
import '../repositories/community_repository.dart';

class GetCommunityDetailsUseCase {
  final CommunityRepository repository;
  GetCommunityDetailsUseCase(this.repository);
  Future<CommunityDetailsEntity> call(String hostelId) =>
      repository.getCommunityDetails(hostelId);
}

class GetCommunityMessagesUseCase {
  final CommunityRepository repository;
  GetCommunityMessagesUseCase(this.repository);
  Future<List<CommunityMessageEntity>> call(
    String hostelId, {
    int limit = 50,
    String? before,
  }) => repository.getMessages(hostelId, limit: limit, before: before);
}

class SendCommunityMessageUseCase {
  final CommunityRepository repository;
  SendCommunityMessageUseCase(this.repository);
  Future<void> call(String hostelId, String text) =>
      repository.sendMessage(hostelId, text);
}

class SendCommunityImageUseCase {
  final CommunityRepository repository;
  SendCommunityImageUseCase(this.repository);
  Future<void> call(String hostelId, String imagePath) =>
      repository.sendImageMessage(hostelId, imagePath);
}

class GetAnnouncementsUseCase {
  final CommunityRepository repository;
  GetAnnouncementsUseCase(this.repository);
  Future<List<AnnouncementEntity>> call(String hostelId) =>
      repository.getAnnouncements(hostelId);
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
  Future<List<OwnerDiscussionEntity>> call(String hostelId) =>
      repository.getOwnerDiscussions(hostelId);
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
  Future<List<CommunityDetailsEntity>> call({Map<String, String>? filters}) =>
      repository.getAvailableOwnerCommunities(filters: filters);
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
    String? coverImagePath,
    String? level,
    String? stateId,
    String? districtId,
    String? wardId,
    String? localityId,
    String? rules,
    String? executiveRole,
    String? fullName,
    String? phoneNumber,
    String? govtCertificatePath,
    String? associationCertificatePath,
  }) async {
    return repository.createOwnerCommunity(
      name: name,
      description: description,
      imagePath: imagePath,
      coverImagePath: coverImagePath,
      level: level,
      stateId: stateId,
      districtId: districtId,
      wardId: wardId,
      localityId: localityId,
      rules: rules,
      executiveRole: executiveRole,
      fullName: fullName,
      phoneNumber: phoneNumber,
      govtCertificatePath: govtCertificatePath,
      associationCertificatePath: associationCertificatePath,
    );
  }
}

class GetPendingJoinRequestsUseCase {
  final CommunityRepository repository;
  GetPendingJoinRequestsUseCase(this.repository);
  Future<List<Map<String, dynamic>>> call() =>
      repository.getPendingJoinRequests();
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
  Future<Map<String, dynamic>> call(String communityId) =>
      repository.getCommunityInfo(communityId);
}

class UpdateOwnerCommunityUseCase {
  final CommunityRepository repository;
  UpdateOwnerCommunityUseCase(this.repository);
  Future<void> call({
    required String communityId,
    String? name,
    String? description,
    String? rules,
    String? imagePath,
    String? coverImagePath,
  }) => repository.updateOwnerCommunity(
    communityId: communityId,
    name: name,
    description: description,
    rules: rules,
    imagePath: imagePath,
    coverImagePath: coverImagePath,
  );
}

class GetAssociationsUseCase {
  final CommunityRepository repository;
  GetAssociationsUseCase(this.repository);
  Future<List<Map<String, dynamic>>> call({String? parentId, String? level}) =>
      repository.getAssociations(parentId: parentId, level: level);
}

class SearchAssociationsUseCase {
  final CommunityRepository repository;
  SearchAssociationsUseCase(this.repository);
  Future<List<Map<String, dynamic>>> call(String query) =>
      repository.searchAssociations(query);
}

class JoinAssociationUseCase {
  final CommunityRepository repository;
  JoinAssociationUseCase(this.repository);
  Future<void> call(String associationId) =>
      repository.joinAssociation(associationId);
}

class CreateAssociationUseCase {
  final CommunityRepository repository;
  CreateAssociationUseCase(this.repository);
  Future<void> call({
    required String name,
    required String level,
    String? parentId,
    String? description,
  }) => repository.createAssociation(
    name: name,
    level: level,
    parentId: parentId,
    description: description,
  );
}

class GetSocialFeedUseCase {
  final CommunityRepository repository;
  GetSocialFeedUseCase(this.repository);
  Future<List<SocialPostEntity>> call({int limit = 20, int skip = 0}) =>
      repository.getSocialFeed(limit: limit, skip: skip);
}

class CreateSocialPostUseCase {
  final CommunityRepository repository;
  CreateSocialPostUseCase(this.repository);
  Future<SocialPostEntity> call({
    String? communityId,
    required String content,
    String type = 'POST',
    String? imagePath,
    List<String>? pollOptions,
    Map<String, dynamic>? location,
  }) => repository.createSocialPost(
    communityId: communityId,
    content: content,
    type: type,
    imagePath: imagePath,
    pollOptions: pollOptions,
    location: location,
  );
}

class TogglePostLikeUseCase {
  final CommunityRepository repository;
  TogglePostLikeUseCase(this.repository);
  Future<void> call(String postId) => repository.togglePostLike(postId);
}

class GetPostCommentsUseCase {
  final CommunityRepository repository;
  GetPostCommentsUseCase(this.repository);
  Future<List<Map<String, dynamic>>> call(
    String postId, {
    int limit = 20,
    int skip = 0,
  }) => repository.getPostComments(postId, limit: limit, skip: skip);
}

class AddPostCommentUseCase {
  final CommunityRepository repository;
  AddPostCommentUseCase(this.repository);
  Future<void> call(String postId, String text) =>
      repository.addPostComment(postId, text);
}

class VotePollUseCase {
  final CommunityRepository repository;
  VotePollUseCase(this.repository);
  Future<void> call(String postId, int optionIndex) =>
      repository.votePoll(postId, optionIndex);
}

class DeleteSocialPostUseCase {
  final CommunityRepository repository;
  DeleteSocialPostUseCase(this.repository);
  Future<void> call(String postId) => repository.deleteSocialPost(postId);
}
