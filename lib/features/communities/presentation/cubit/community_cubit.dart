import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stayindia_owner/features/communities/domain/entities/community_entity.dart';
import 'package:stayindia_owner/features/communities/domain/usecases/community_usecases.dart';
import 'package:stayindia_owner/core/utils/error_helper.dart';
import 'package:stayindia_owner/core/utils/logger.dart';
import 'package:stayindia_owner/core/socket/socket_service.dart';
import 'dart:async';
import '../../data/models/community_model.dart';

part 'community_state.dart';

class CommunityCubit extends Cubit<CommunityState> {
  final GetCommunityDetailsUseCase _getDetails;
  final GetCommunityMessagesUseCase _getMessages;
  final SendCommunityMessageUseCase _sendMessage;
  final GetAnnouncementsUseCase _getAnnouncements;
  final PostAnnouncementUseCase _postAnnouncement;
  final GetOwnerDiscussionsUseCase _getDiscussions;
  final CreateOwnerDiscussionUseCase _createDiscussion;
  final SocketService _socketService;
  StreamSubscription? _messageSubscription;
  String? _currentHostelId;

  CommunityCubit({
    required GetCommunityDetailsUseCase getCommunityDetailsUseCase,
    required GetCommunityMessagesUseCase getCommunityMessagesUseCase,
    required SendCommunityMessageUseCase sendCommunityMessageUseCase,
    required GetAnnouncementsUseCase getAnnouncementsUseCase,
    required PostAnnouncementUseCase postAnnouncementUseCase,
    required GetOwnerDiscussionsUseCase getOwnerDiscussionsUseCase,
    required CreateOwnerDiscussionUseCase createOwnerDiscussionUseCase,
    required SocketService socketService,
  })  : _getDetails = getCommunityDetailsUseCase,
        _getMessages = getCommunityMessagesUseCase,
        _sendMessage = sendCommunityMessageUseCase,
        _getAnnouncements = getAnnouncementsUseCase,
        _postAnnouncement = postAnnouncementUseCase,
        _getDiscussions = getOwnerDiscussionsUseCase,
        _createDiscussion = createOwnerDiscussionUseCase,
        _socketService = socketService,
        super(CommunityInitial());

  

  Future<void> loadCommunityData(String hostelId) async {
    if (isClosed) return;
    emit(CommunityLoading());
    try {
      final results = await Future.wait([
        _getDetails(hostelId),
        _getMessages(hostelId, limit: 50), 
        _getAnnouncements(hostelId),
        _getDiscussions(hostelId),
      ]);

      if (isClosed) return;
      final messages = results[1] as List<CommunityMessageEntity>;
      emit(CommunityLoaded(
        details: results[0] as CommunityDetailsEntity,
        messages: messages,
        announcements: results[2] as List<AnnouncementEntity>,
        discussions: results[3] as List<OwnerDiscussionEntity>,
        hasMoreMessages: messages.length >= 50, 
      ));
    } catch (e) {
      AppLogger.error('loadCommunityData failed', e);
      if (!isClosed) emit(CommunityError(message: ErrorHelper.toFriendlyMessage(e)));
    }
  }

  Future<void> refreshMessages(String hostelId) async {
    final s = state;
    if (s is CommunityLoaded) {
      try {
        
        final messages = await _getMessages(hostelId, limit: 50);
        if (!isClosed) emit(s.copyWith(messages: messages));
      } catch (e) {
        AppLogger.error('refreshMessages failed', e);
      }
    }
  }

  
  
  Future<void> loadOlderMessages(String hostelId) async {
    final s = state;
    if (s is! CommunityLoaded || !s.hasMoreMessages || s.isLoadingMoreMessages) return;

    emit(s.copyWith(isLoadingMoreMessages: true));
    try {
      
      final oldestId = s.messages.isNotEmpty ? s.messages.first.id : null;
      final older = await _getMessages(hostelId, limit: 50, before: oldestId);
      if (isClosed) return;
      final updatedState = state;
      if (updatedState is CommunityLoaded) {
        emit(updatedState.copyWith(
          messages: [...older, ...updatedState.messages], 
          hasMoreMessages: older.length >= 50,
          isLoadingMoreMessages: false,
        ));
      }
    } catch (e) {
      AppLogger.error('loadOlderMessages failed', e);
      final s2 = state;
      if (!isClosed && s2 is CommunityLoaded) {
        emit(s2.copyWith(isLoadingMoreMessages: false));
      }
    }
  }

  Future<void> joinCommunity(String hostelId, String userId) async {
    AppLogger.debug(' CommunityCubit: Requesting to join room $hostelId for user $userId');
    _currentHostelId = hostelId;
    _socketService.joinCommunity(hostelId, userId);
    
    _messageSubscription?.cancel();
    _messageSubscription = _socketService.messageStream.listen((data) {
      final s = state;
      if (s is CommunityLoaded) {
        final newMessage = CommunityMessageModel.fromJson(data);
        
        final updatedMessages = List<CommunityMessageEntity>.from(s.messages)..add(newMessage);
        emit(s.copyWith(messages: updatedMessages));
      }
    });
  }

  Future<void> leaveCommunity() async {
    if (_currentHostelId != null) {
      _socketService.leaveCommunity(_currentHostelId!);
    }
    _messageSubscription?.cancel();
    _messageSubscription = null;
    _currentHostelId = null;
  }

  Future<void> sendMessage(String hostelId, String text) async {
    try {
      await _sendMessage(hostelId, text);
      
    } catch (e) {
      AppLogger.error('sendMessage failed', e);
    }
  }

  Future<void> postAnnouncement(String hostelId, String title, String content) async {
    final s = state;
    if (s is CommunityLoaded) {
      try {
        await _postAnnouncement(hostelId, title, content);
        final announcements = await _getAnnouncements(hostelId);
        emit(s.copyWith(announcements: announcements));
      } catch (e) {
        AppLogger.error('postAnnouncement failed', e);
        emit(CommunityError(message: ErrorHelper.toFriendlyMessage(e)));
      }
    }
  }

  Future<void> createDiscussion({
    required String title,
    required String description,
    required String type,
    String? hostelId,
  }) async {
    final s = state;
    if (s is CommunityLoaded) {
      try {
        await _createDiscussion(
          title: title,
          description: description,
          type: type,
          hostelId: hostelId,
        );
        if (hostelId != null) {
          final discussions = await _getDiscussions(hostelId);
          emit(s.copyWith(discussions: discussions));
        }
      } catch (e) {
        AppLogger.error('createDiscussion failed', e);
        emit(CommunityError(message: ErrorHelper.toFriendlyMessage(e)));
      }
    }
  }

  @override
  Future<void> close() {
    leaveCommunity();
    return super.close();
  }
}
