part of 'community_cubit.dart';

abstract class CommunityState extends Equatable {
  const CommunityState();
  @override
  List<Object?> get props => [];
}

class CommunityInitial extends CommunityState {}
class CommunityLoading extends CommunityState {}

class CommunityLoaded extends CommunityState {
  final CommunityDetailsEntity? details;
  final List<CommunityMessageEntity> messages;
  final List<AnnouncementEntity> announcements;
  final List<OwnerDiscussionEntity> discussions;
  
  final bool hasMoreMessages;
  final bool isLoadingMoreMessages;

  const CommunityLoaded({
    this.details,
    this.messages = const [],
    this.announcements = const [],
    this.discussions = const [],
    this.hasMoreMessages = true,
    this.isLoadingMoreMessages = false,
  });

  CommunityLoaded copyWith({
    CommunityDetailsEntity? details,
    List<CommunityMessageEntity>? messages,
    List<AnnouncementEntity>? announcements,
    List<OwnerDiscussionEntity>? discussions,
    bool? hasMoreMessages,
    bool? isLoadingMoreMessages,
  }) {
    return CommunityLoaded(
      details: details ?? this.details,
      messages: messages ?? this.messages,
      announcements: announcements ?? this.announcements,
      discussions: discussions ?? this.discussions,
      hasMoreMessages: hasMoreMessages ?? this.hasMoreMessages,
      isLoadingMoreMessages: isLoadingMoreMessages ?? this.isLoadingMoreMessages,
    );
  }

  @override
  List<Object?> get props => [details, messages, announcements, discussions, hasMoreMessages, isLoadingMoreMessages];
}

class CommunityError extends CommunityState {
  final String message;
  const CommunityError({required this.message});
  @override
  List<Object?> get props => [message];
}
