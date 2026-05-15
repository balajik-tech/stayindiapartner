import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stayindia_owner/features/communities/domain/entities/community_entity.dart';
import 'package:stayindia_owner/features/communities/domain/usecases/community_usecases.dart';
import 'package:stayindia_owner/core/utils/error_helper.dart';

abstract class SocialFeedState extends Equatable {
  const SocialFeedState();
  @override
  List<Object?> get props => [];
}

class SocialFeedInitial extends SocialFeedState {}

class SocialFeedLoading extends SocialFeedState {}

class SocialFeedLoaded extends SocialFeedState {
  final List<SocialPostEntity> posts;
  final bool isCreatingPost;
  final bool isFetchingMore;
  final bool hasReachedMax;

  const SocialFeedLoaded({
    required this.posts,
    this.isCreatingPost = false,
    this.isFetchingMore = false,
    this.hasReachedMax = false,
  });

  SocialFeedLoaded copyWith({
    List<SocialPostEntity>? posts,
    bool? isCreatingPost,
    bool? isFetchingMore,
    bool? hasReachedMax,
  }) {
    return SocialFeedLoaded(
      posts: posts ?? this.posts,
      isCreatingPost: isCreatingPost ?? this.isCreatingPost,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
    );
  }

  @override
  List<Object?> get props => [posts, isCreatingPost, isFetchingMore, hasReachedMax];
}

class SocialFeedError extends SocialFeedState {
  final String message;
  const SocialFeedError({required this.message});
  @override
  List<Object?> get props => [message];
}

class SocialFeedCubit extends Cubit<SocialFeedState> {
  final GetSocialFeedUseCase _getSocialFeed;
  final CreateSocialPostUseCase _createSocialPost;
  final TogglePostLikeUseCase _togglePostLike;
  final AddPostCommentUseCase _addPostComment;
  final VotePollUseCase _votePoll;
  final DeleteSocialPostUseCase _deleteSocialPost;

  SocialFeedCubit({
    required GetSocialFeedUseCase getSocialFeedUseCase,
    required CreateSocialPostUseCase createSocialPostUseCase,
    required TogglePostLikeUseCase togglePostLikeUseCase,
    required AddPostCommentUseCase addPostCommentUseCase,
    required VotePollUseCase votePollUseCase,
    required DeleteSocialPostUseCase deleteSocialPostUseCase,
  })  : _getSocialFeed = getSocialFeedUseCase,
        _createSocialPost = createSocialPostUseCase,
        _togglePostLike = togglePostLikeUseCase,
        _addPostComment = addPostCommentUseCase,
        _votePoll = votePollUseCase,
        _deleteSocialPost = deleteSocialPostUseCase,
        super(SocialFeedInitial());

  Future<void> loadFeed({bool isRefresh = false}) async {
    final s = state;
    if (s is SocialFeedLoaded && isRefresh) {
    } else {
      emit(SocialFeedLoading());
    }

    try {
      final posts = await _getSocialFeed(limit: 20, skip: 0);
      if (state is SocialFeedLoaded && isRefresh) {
        emit((state as SocialFeedLoaded).copyWith(posts: posts));
      } else {
        emit(SocialFeedLoaded(
          posts: posts,
          hasReachedMax: posts.length < 20,
        ));
      }
    } catch (e) {
      emit(SocialFeedError(message: ErrorHelper.toFriendlyMessage(e)));
    }
  }

  Future<void> loadMoreFeed() async {
    final s = state;
    if (s is SocialFeedLoaded && !s.isFetchingMore && !s.hasReachedMax) {
      emit(s.copyWith(isFetchingMore: true));
      try {
        final nextPosts = await _getSocialFeed(limit: 20, skip: s.posts.length);
        emit(s.copyWith(
          posts: [...s.posts, ...nextPosts],
          isFetchingMore: false,
          hasReachedMax: nextPosts.length < 20,
        ));
      } catch (e) {
        emit(s.copyWith(isFetchingMore: false));
      }
    }
  }

  Future<void> createPost({
    required String content,
    String? imagePath,
    String type = 'POST',
    List<String>? pollOptions,
    Map<String, dynamic>? location,
  }) async {
    final s = state;
    if (s is SocialFeedLoaded) {
      emit(s.copyWith(isCreatingPost: true));
      try {
        final newPost = await _createSocialPost(
          content: content,
          imagePath: imagePath,
          type: type,
          pollOptions: pollOptions,
          location: location,
        );
        emit(s.copyWith(
          posts: [newPost, ...s.posts],
          isCreatingPost: false,
        ));
      } catch (e) {
        emit(SocialFeedError(message: ErrorHelper.toFriendlyMessage(e)));
      }
    } else {
      emit(SocialFeedLoading());
      try {
        await _createSocialPost(
          content: content,
          imagePath: imagePath,
          type: type,
          pollOptions: pollOptions,
          location: location,
        );
        await loadFeed(isRefresh: true);
      } catch (e) {
        emit(SocialFeedError(message: ErrorHelper.toFriendlyMessage(e)));
      }
    }
  }

  Future<void> toggleLike(String postId) async {
    final s = state;
    if (s is SocialFeedLoaded) {
      final updatedPosts = s.posts.map((p) {
        if (p.id == postId) {
          final isLiked = !p.isLiked;
          final count = isLiked ? p.likesCount + 1 : p.likesCount - 1;
          return p.copyWith(isLiked: isLiked, likesCount: count);
        }
        return p;
      }).toList();
      emit(s.copyWith(posts: updatedPosts));

      try {
        await _togglePostLike(postId);
      } catch (e) {
        await loadFeed(isRefresh: true);
      }
    }
  }

  Future<void> addComment(String postId, String text) async {
    final s = state;
    if (s is SocialFeedLoaded) {
      final updatedPosts = s.posts.map((p) {
        if (p.id == postId) {
          return p.copyWith(commentsCount: p.commentsCount + 1);
        }
        return p;
      }).toList();
      emit(s.copyWith(posts: updatedPosts));

      try {
        await _addPostComment(postId, text);
      } catch (e) {
        await loadFeed(isRefresh: true);
      }
    }
  }

  Future<void> votePoll(String postId, int optionIndex) async {
    final s = state;
    if (s is SocialFeedLoaded) {
      final targetPost = s.posts.where((p) => p.id == postId).firstOrNull;
      if (targetPost != null && targetPost.userVote != null) {
        return;
      }

      final updatedPosts = s.posts.map((p) {
        if (p.id == postId && p.poll != null) {
          final opts = List<dynamic>.from(p.poll!['options'] ?? []);
          final newOpts = opts.map((opt) => Map<String, dynamic>.from(opt)).toList();

          if (optionIndex >= 0 && optionIndex < newOpts.length) {
            final newCount = ((newOpts[optionIndex]['votesCount'] ?? newOpts[optionIndex]['votes'] ?? 0) as num).toInt();
            newOpts[optionIndex]['votesCount'] = newCount + 1;
          }

          final newPoll = Map<String, dynamic>.from(p.poll!);
          newPoll['options'] = newOpts;

          return p.copyWith(userVote: optionIndex, poll: newPoll);
        }
        return p;
      }).toList();

      emit(s.copyWith(posts: updatedPosts));

      try {
        await _votePoll(postId, optionIndex);
        final posts = await _getSocialFeed(limit: 20, skip: 0);
        if (state is SocialFeedLoaded) {
          emit((state as SocialFeedLoaded).copyWith(posts: posts));
        }
      } catch (e) {
        final posts = await _getSocialFeed(limit: 20, skip: 0);
        if (state is SocialFeedLoaded) {
          emit((state as SocialFeedLoaded).copyWith(posts: posts));
        }
      }
    }
  }

  Future<void> deletePost(String postId) async {
    final s = state;
    if (s is SocialFeedLoaded) {
      try {
        await _deleteSocialPost(postId);
        final posts = await _getSocialFeed(limit: 20, skip: 0);
        if (state is SocialFeedLoaded) {
          emit((state as SocialFeedLoaded).copyWith(posts: posts));
        }
      } catch (e) {
        emit(SocialFeedError(message: ErrorHelper.toFriendlyMessage(e)));
      }
    }
  }
}
