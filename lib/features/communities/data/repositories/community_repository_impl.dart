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
  }) =>
      remote.getMessages(hostelId, limit: limit, before: before);

  @override
  Future<void> sendMessage(String hostelId, String text) => 
      remote.sendMessage(hostelId, text);

  @override
  Future<List<AnnouncementEntity>> getAnnouncements(String hostelId) => 
      remote.getAnnouncements(hostelId);

  @override
  Future<void> postAnnouncement(String hostelId, String title, String content) => 
      remote.postAnnouncement(hostelId, title, content);

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
  Future<List<CommunityDetailsEntity>> getAvailableOwnerCommunities() =>
      remote.getAvailableOwnerCommunities();

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
  }) =>
      remote.handleJoinRequest(communityId, requesterId, action);

  @override
  Future<Map<String, dynamic>> getCommunityInfo(String communityId) =>
      remote.getCommunityInfo(communityId);

  @override
  Future<void> createOwnerCommunity({
    required String name,
    String? description,
    String? imagePath,
  }) =>
      remote.createOwnerCommunity(
        name: name,
        description: description,
        imagePath: imagePath,
      );
}
