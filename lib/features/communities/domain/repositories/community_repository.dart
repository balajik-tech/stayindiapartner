import '../entities/community_entity.dart';

abstract class CommunityRepository {
  
  Future<CommunityDetailsEntity> getCommunityDetails(String hostelId);
  Future<List<CommunityMessageEntity>> getMessages(
    String hostelId, {
    int limit = 50,
    String? before,
  });
  Future<void> sendMessage(String hostelId, String text);
  Future<void> sendImageMessage(String hostelId, String imagePath);
  
  
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
  Future<List<CommunityDetailsEntity>> getAvailableOwnerCommunities({Map<String, String>? filters});
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
    String? coverImagePath,
    String? level,
    String? stateId,
    String? districtId,
    String? wardId,
    String? localityId,
  });

  
  Future<List<Map<String, dynamic>>> getAssociations({String? parentId, String? level});
  Future<void> joinAssociation(String associationId);
  Future<void> createAssociation({
    required String name,
    required String level,
    String? parentId,
    String? description,
  });
  Future<void> updateOwnerCommunity({
    required String communityId,
    String? name,
    String? description,
    String? imagePath,
    String? coverImagePath,
  });
  Future<void> removeMember({
    required String communityId,
    required String memberId,
  });
  Future<void> broadcastSOS({
    required String associationId,
    required String issueType,
    required String description,
    String severity = 'HIGH',
  });
}
