import 'package:stayindia_owner/features/communities/domain/entities/community_entity.dart';
import 'package:stayindia_owner/features/communities/domain/repositories/community_repository.dart';
import '../datasources/community_remote_datasource.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  final CommunityRemoteDataSource remote;

  CommunityRepositoryImpl({required this.remote});

  @override
  Future<CommunityDetailsEntity> getCommunityDetails(String hostelId) =>
      remote.getCommunityDetails(hostelId);

  @override
  Future<List<CommunityMessageEntity>> getMessages(
    String hostelId, {
    int limit = 50,
    String? before,
  }) => remote.getMessages(hostelId, limit: limit, before: before);

  @override
  Future<void> sendMessage(String hostelId, String text) =>
      remote.sendMessage(hostelId, text);

  @override
  Future<void> sendImageMessage(String hostelId, String imagePath) =>
      remote.sendImageMessage(hostelId, imagePath);

  @override
  Future<List<AnnouncementEntity>> getAnnouncements(String hostelId) =>
      remote.getAnnouncements(hostelId);

  @override
  Future<void> postAnnouncement(
    String hostelId,
    String title,
    String content,
  ) => remote.postAnnouncement(hostelId, title, content);

  @override
  Future<List<OwnerDiscussionEntity>> getOwnerDiscussions(String hostelId) =>
      remote.getOwnerDiscussions(hostelId);

  @override
  Future<void> createOwnerDiscussion({
    required String title,
    required String description,
    required String type,
    String? hostelId,
  }) => remote.createOwnerDiscussion(
    title: title,
    description: description,
    type: type,
    hostelId: hostelId,
  );

  @override
  Future<List<CommunityDetailsEntity>> getJoinedOwnerCommunities() =>
      remote.getJoinedOwnerCommunities();

  @override
  Future<List<CommunityDetailsEntity>> getAvailableOwnerCommunities({
    Map<String, String>? filters,
  }) => remote.getAvailableOwnerCommunities(filters: filters);

  @override
  Future<void> joinOwnerCommunity(String communityId) =>
      remote.joinOwnerCommunity(communityId);

  @override
  Future<List<Map<String, dynamic>>> getPendingJoinRequests() =>
      remote.getPendingJoinRequests();

  @override
  Future<void> handleJoinRequest({
    required String communityId,
    required String requesterId,
    required String action,
  }) => remote.handleJoinRequest(communityId, requesterId, action);

  @override
  Future<Map<String, dynamic>> getCommunityInfo(String communityId) =>
      remote.getCommunityInfo(communityId);

  @override
  Future<void> createOwnerCommunity({
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
  }) => remote.createOwnerCommunity(
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

  @override
  Future<List<Map<String, dynamic>>> getAssociations({
    String? parentId,
    String? level,
  }) => remote.getAssociations(parentId: parentId, level: level);

  @override
  Future<void> joinAssociation(String associationId) =>
      remote.joinAssociation(associationId);

  @override
  Future<void> createAssociation({
    required String name,
    required String level,
    String? parentId,
    String? description,
  }) => remote.createAssociation(
    name: name,
    level: level,
    parentId: parentId,
    description: description,
  );

  @override
  Future<List<Map<String, dynamic>>> searchAssociations(String query) =>
      remote.searchAssociations(query);

  @override
  Future<void> updateOwnerCommunity({
    required String communityId,
    String? name,
    String? description,
    String? rules,
    String? imagePath,
    String? coverImagePath,
  }) => remote.updateOwnerCommunity(
    communityId: communityId,
    name: name,
    description: description,
    rules: rules,
    imagePath: imagePath,
    coverImagePath: coverImagePath,
  );

  @override
  Future<void> removeMember({
    required String communityId,
    required String memberId,
  }) => remote.removeMember(communityId, memberId);

  @override
  Future<void> broadcastSOS({
    required String associationId,
    required String issueType,
    required String description,
    String severity = 'HIGH',
  }) => remote.broadcastSOS(
    associationId: associationId,
    issueType: issueType,
    description: description,
    severity: severity,
  );

  @override
  Future<List<SocialPostEntity>> getSocialFeed({
    int limit = 20,
    int skip = 0,
  }) => remote.getSocialFeed(limit: limit, skip: skip);

  @override
  Future<SocialPostEntity> createSocialPost({
    String? communityId,
    required String content,
    String type = 'POST',
    String? imagePath,
    List<String>? pollOptions,
    Map<String, dynamic>? location,
  }) => remote.createSocialPost(
    communityId: communityId,
    content: content,
    type: type,
    imagePath: imagePath,
    pollOptions: pollOptions,
    location: location,
  );

  @override
  Future<void> togglePostLike(String postId) => remote.togglePostLike(postId);

  @override
  Future<List<Map<String, dynamic>>> getPostComments(
    String postId, {
    int limit = 20,
    int skip = 0,
  }) => remote.getPostComments(postId, limit: limit, skip: skip);

  @override
  Future<void> addPostComment(String postId, String text) =>
      remote.addPostComment(postId, text);

  @override
  Future<void> votePoll(String postId, int optionIndex) =>
      remote.votePoll(postId, optionIndex);

  @override
  Future<void> deleteSocialPost(String postId) =>
      remote.deleteSocialPost(postId);
}
