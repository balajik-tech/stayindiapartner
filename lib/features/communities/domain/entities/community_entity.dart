import 'package:equatable/equatable.dart';

class CommunityDetailsEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? image;
  final int memberCount;
  final String? status;
  final String? level;
  final String? stateId;
  final String? districtId;
  final String? wardId;

  const CommunityDetailsEntity({
    required this.id,
    required this.name,
    this.description,
    this.image,
    required this.memberCount,
    this.status,
    this.level,
    this.stateId,
    this.districtId,
    this.wardId,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        image,
        memberCount,
        status,
        level,
        stateId,
        districtId,
        wardId
      ];
}

class CommunityMessageEntity extends Equatable {
  final String id;
  final String senderId;
  final String senderName;
  final String? senderAvatar;
  final String text;
  final String? imageUrl;
  final String? roomId;
  final DateTime createdAt;
  final String type;
  final bool isSystem;
  final bool isMe;
  final String? associationLevel;
  final bool isVerified;

  const CommunityMessageEntity({
    required this.id,
    required this.senderId,
    required this.senderName,
    this.senderAvatar,
    this.text = '',
    this.imageUrl,
    this.roomId,
    required this.createdAt,
    this.type = 'TEXT',
    this.isSystem = false,
    this.isMe = false,
    this.associationLevel,
    this.isVerified = false,
  });

  @override
  List<Object?> get props => [id, senderId, senderName, senderAvatar, text, imageUrl, roomId, createdAt, type, isSystem, isMe, associationLevel, isVerified];
}

class AnnouncementEntity extends Equatable {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final String? authorName;

  const AnnouncementEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    this.authorName,
  });

  @override
  List<Object?> get props => [id, title, content, createdAt, authorName];
}

class OwnerDiscussionEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String type;
  final DateTime createdAt;
  final String? authorName;

  const OwnerDiscussionEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.createdAt,
    this.authorName,
  });

  @override
  List<Object?> get props => [id, title, description, type, createdAt, authorName];
}

class SocialPostEntity extends Equatable {
  final String id;
  final String userId;
  final String userName;
  final String? userAvatar;
  final String? userRole;
  final String content;
  final String type;
  final int likesCount;
  final int commentsCount;
  final bool isLiked;
  final DateTime createdAt;
  final String? visibility;
  final Map<String, dynamic>? poll;
  final int? userVote;
  final String? imageUrl;
  final String? videoUrl;
  final Map<String, dynamic>? location;

  const SocialPostEntity({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    this.userRole,
    required this.content,
    required this.type,
    required this.likesCount,
    required this.commentsCount,
    required this.isLiked,
    required this.createdAt,
    this.visibility,
    this.poll,
    this.userVote,
    this.imageUrl,
    this.videoUrl,
    this.location,
  });

  SocialPostEntity copyWith({
    String? id,
    String? userId,
    String? userName,
    String? userAvatar,
    String? userRole,
    String? content,
    String? type,
    int? likesCount,
    int? commentsCount,
    bool? isLiked,
    DateTime? createdAt,
    String? visibility,
    Map<String, dynamic>? poll,
    int? userVote,
    String? imageUrl,
    String? videoUrl,
    Map<String, dynamic>? location,
  }) {
    return SocialPostEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
      userRole: userRole ?? this.userRole,
      content: content ?? this.content,
      type: type ?? this.type,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      isLiked: isLiked ?? this.isLiked,
      createdAt: createdAt ?? this.createdAt,
      visibility: visibility ?? this.visibility,
      poll: poll ?? this.poll,
      userVote: userVote ?? this.userVote,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      location: location ?? this.location,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        userName,
        userAvatar,
        userRole,
        content,
        type,
        likesCount,
        commentsCount,
        isLiked,
        createdAt,
        visibility,
        poll,
        userVote,
        imageUrl,
        videoUrl,
        location,
      ];
}
