import 'package:stayindia_owner/features/communities/domain/entities/community_entity.dart';

class CommunityDetailsModel extends CommunityDetailsEntity {
  const CommunityDetailsModel({
    required super.id,
    required super.name,
    super.description,
    super.image,
    required super.memberCount,
    super.status,
    super.level,
    super.stateId,
    super.districtId,
    super.wardId,
    super.isPendingJoin,
  });

  factory CommunityDetailsModel.fromJson(Map<String, dynamic> json) {
    return CommunityDetailsModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      image: json['image']?.toString() ?? json['coverImage']?.toString(),
      memberCount: json['memberCount'] ?? 0,
      status: json['status']?.toString(),
      level: json['level']?.toString(),
      stateId: json['stateId']?.toString(),
      districtId: json['districtId']?.toString(),
      wardId: json['wardId']?.toString(),
      isPendingJoin: json['isPendingJoin'] ?? false,
    );
  }
}

class CommunityMessageModel extends CommunityMessageEntity {
  const CommunityMessageModel({
    required super.id,
    required super.senderId,
    required super.senderName,
    super.senderAvatar,
    required super.text,
    super.imageUrl,
    super.roomId,
    required super.createdAt,
    super.type,
    super.isSystem,
    super.isMe,
  });

  factory CommunityMessageModel.fromJson(Map<String, dynamic> json) {
    final senderData = json['sender'] is Map
        ? json['sender'] as Map<String, dynamic>
        : null;
    final userData = json['user'] is Map
        ? json['user'] as Map<String, dynamic>
        : null;
    final authorData = json['author'] is Map
        ? json['author'] as Map<String, dynamic>
        : null;

    String sId = '';
    if (json['senderId'] != null) {
      sId = json['senderId'].toString();
    } else if (json['sender'] != null) {
      if (json['sender'] is Map) {
        sId = (json['sender']['_id'] ?? json['sender']['id'] ?? '').toString();
      } else {
        sId = json['sender'].toString();
      }
    } else {
      sId = (json['authorId'] ?? json['userId'] ?? json['user_id'] ?? '')
          .toString();
    }

    final type = json['type']?.toString() ?? 'TEXT';
    return CommunityMessageModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      senderId: sId,
      senderName:
          json['senderName']?.toString() ??
          senderData?['name']?.toString() ??
          userData?['name']?.toString() ??
          senderData?['firstName']?.toString() ??
          userData?['firstName']?.toString() ??
          authorData?['name']?.toString() ??
          'Unknown',
      senderAvatar:
          json['senderAvatar']?.toString() ??
          senderData?['avatar']?.toString() ??
          userData?['avatar']?.toString() ??
          authorData?['avatar']?.toString() ??
          senderData?['image']?.toString() ??
          json['avatar']?.toString(),
      text: json['text']?.toString() ?? '',
      imageUrl: json['image']?.toString(),
      roomId: json['roomId']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString()).toLocal()
          : DateTime.now(),
      type: type,
      isSystem: type == 'SYSTEM',
      isMe: json['isMe'] ?? false,
    );
  }
}

class AnnouncementModel extends AnnouncementEntity {
  const AnnouncementModel({
    required super.id,
    required super.title,
    required super.content,
    required super.createdAt,
    super.authorName,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString()).toLocal()
          : DateTime.now(),
      authorName: json['authorName']?.toString(),
    );
  }
}

class OwnerDiscussionModel extends OwnerDiscussionEntity {
  const OwnerDiscussionModel({
    required super.id,
    required super.title,
    required super.description,
    required super.type,
    required super.createdAt,
    super.authorName,
  });

  factory OwnerDiscussionModel.fromJson(Map<String, dynamic> json) {
    return OwnerDiscussionModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString()).toLocal()
          : DateTime.now(),
      authorName: json['authorName']?.toString(),
    );
  }
}

class SocialPostModel extends SocialPostEntity {
  const SocialPostModel({
    required super.id,
    required super.userId,
    required super.userName,
    super.userAvatar,
    super.userRole,
    required super.content,
    required super.type,
    required super.likesCount,
    required super.commentsCount,
    required super.isLiked,
    required super.createdAt,
    super.visibility,
    super.poll,
    super.userVote,
    super.imageUrl,
    super.videoUrl,
    super.location,
  });

  factory SocialPostModel.fromJson(Map<String, dynamic> json) {
    final userField = json['userId'];
    final userData = userField is Map
        ? userField as Map<String, dynamic>
        : (json['user'] is Map ? json['user'] as Map<String, dynamic> : null);
    final authorData = json['author'] is Map
        ? json['author'] as Map<String, dynamic>
        : null;

    return SocialPostModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      userId:
          (userData?['_id'] ??
                  userData?['id'] ??
                  (userField is String ? userField : ''))
              .toString(),
      userName: (json['userName']?.toString().isNotEmpty == true)
          ? json['userName']
          : (userData?['name']?.toString().isNotEmpty == true)
          ? userData!['name']
          : (userData?['firstName']?.toString().isNotEmpty == true)
          ? '${userData!['firstName']}${userData['lastName'] != null ? ' ${userData['lastName']}' : ''}'
          : (authorData?['name']?.toString().isNotEmpty == true)
          ? authorData!['name']
          : 'Unknown',
      userAvatar:
          json['userAvatar']?.toString() ??
          userData?['avatar']?.toString() ??
          authorData?['avatar']?.toString(),
      userRole:
          json['userRole']?.toString() ??
          userData?['role']?.toString() ??
          authorData?['role']?.toString(),
      content: json['content']?.toString() ?? '',
      type: json['type']?.toString() ?? 'POST',
      likesCount: json['likesCount'] ?? json['likes_count'] ?? 0,
      commentsCount: json['commentsCount'] ?? json['comments_count'] ?? 0,
      isLiked: json['isLiked'] ?? json['is_liked'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      visibility: json['visibility']?.toString(),
      poll: json['poll'] is Map ? json['poll'] as Map<String, dynamic> : null,
      userVote: json['userVote'] as int?,
      imageUrl: json['image']?.toString() ?? json['imageUrl']?.toString(),
      videoUrl: json['video']?.toString() ?? json['videoUrl']?.toString(),
      location: json['location'] is Map
          ? json['location'] as Map<String, dynamic>
          : null,
    );
  }
}
