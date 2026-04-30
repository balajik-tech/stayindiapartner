import 'package:equatable/equatable.dart';

class CommunityDetailsEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? image;
  final int memberCount;
  final String? status;
  final String? level;

  const CommunityDetailsEntity({
    required this.id,
    required this.name,
    this.description,
    this.image,
    required this.memberCount,
    this.status,
    this.level,
  });

  @override
  List<Object?> get props => [id, name, description, image, memberCount, status, level];
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
