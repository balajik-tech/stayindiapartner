import '../entities/community_entity.dart';

abstract class CommunityRepository {
  
  Future<CommunityDetailsEntity> getCommunityDetails(String hostelId);
  Future<List<CommunityMessageEntity>> getMessages(
    String hostelId, {
    int limit = 50,
    String? before,
  });
  Future<void> sendMessage(String hostelId, String text);
  
  
  Future<List<AnnouncementEntity>> getAnnouncements(String hostelId);
  Future<void> postAnnouncement(String hostelId, String title, String content);
  
  
  Future<List<OwnerDiscussionEntity>> getOwnerDiscussions(String hostelId);
  Future<void> createOwnerDiscussion({
    required String title,
    required String description,
    required String type,
    String? hostelId,
  });

  
  Future<List<CommunityDetailsEntity>> getJoinedOwnerCommunities();
  Future<List<CommunityDetailsEntity>> getAvailableOwnerCommunities();
  Future<void> joinOwnerCommunity(String communityId);
  Future<List<Map<String, dynamic>>> getPendingJoinRequests();
  Future<void> handleJoinRequest({
    required String communityId,
    required String requesterId,
    required String action,
  });
  Future<Map<String, dynamic>> getCommunityInfo(String communityId);
  Future<void> createOwnerCommunity({
    required String name,
    String? description,
    String? imagePath,
  });
}
