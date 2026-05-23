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
  final EditCommunityMessageUseCase _editMessage;
  final DeleteCommunityMessageUseCase _deleteMessage;
  final SendCommunityImageUseCase _sendImage;
  final GetAnnouncementsUseCase _getAnnouncements;
  final PostAnnouncementUseCase _postAnnouncement;
  final GetOwnerDiscussionsUseCase _getDiscussions;
  final CreateOwnerDiscussionUseCase _createDiscussion;
  final SocketService _socketService;

  StreamSubscription? _messageSubscription;
  StreamSubscription? _messageEditedSubscription;
  StreamSubscription? _messageDeletedSubscription;
  String? _activeHostelId;

  final Map<String, List<CommunityMessageEntity>> _messagesCache = {};
  final Map<String, CommunityDetailsEntity> _detailsCache = {};
  final Map<String, List<AnnouncementEntity>> _announcementsCache = {};
  final Map<String, List<OwnerDiscussionEntity>> _discussionsCache = {};
  final Map<String, bool> _hasMoreMessagesCache = {};

  CommunityCubit({
    required GetCommunityDetailsUseCase getCommunityDetailsUseCase,
    required GetCommunityMessagesUseCase getCommunityMessagesUseCase,
    required SendCommunityMessageUseCase sendCommunityMessageUseCase,
    required EditCommunityMessageUseCase editCommunityMessageUseCase,
    required DeleteCommunityMessageUseCase deleteCommunityMessageUseCase,
    required SendCommunityImageUseCase sendCommunityImageUseCase,
    required GetAnnouncementsUseCase getAnnouncementsUseCase,
    required PostAnnouncementUseCase postAnnouncementUseCase,
    required GetOwnerDiscussionsUseCase getOwnerDiscussionsUseCase,
    required CreateOwnerDiscussionUseCase createOwnerDiscussionUseCase,
    required SocketService socketService,
  }) : _getDetails = getCommunityDetailsUseCase,
       _getMessages = getCommunityMessagesUseCase,
       _sendMessage = sendCommunityMessageUseCase,
       _editMessage = editCommunityMessageUseCase,
       _deleteMessage = deleteCommunityMessageUseCase,
       _sendImage = sendCommunityImageUseCase,
       _getAnnouncements = getAnnouncementsUseCase,
       _postAnnouncement = postAnnouncementUseCase,
       _getDiscussions = getOwnerDiscussionsUseCase,
       _createDiscussion = createOwnerDiscussionUseCase,
       _socketService = socketService,
       super(CommunityInitial()) {
    _initSocketListener();
  }

  void _initSocketListener() {
    _messageSubscription?.cancel();
    _messageSubscription = _socketService.messageStream.listen((data) {
      final newMessage = CommunityMessageModel.fromJson(data);
      final roomId = newMessage.roomId ?? _activeHostelId;

      if (roomId != null) {
        final currentMessages = _messagesCache[roomId] ?? [];

        if (!currentMessages.any((m) => m.id == newMessage.id)) {
          final updatedMessages = currentMessages
              .where(
                (m) => !(m.id.startsWith('temp_') && m.text == newMessage.text),
              )
              .toList();

          _messagesCache[roomId] = [...updatedMessages, newMessage];

          if (roomId == _activeHostelId && state is CommunityLoaded) {
            emit(
              (state as CommunityLoaded).copyWith(
                messages: _messagesCache[roomId],
              ),
            );
          }
        }
      }
    });

    _messageEditedSubscription?.cancel();
    _messageEditedSubscription = _socketService.messageEditedStream.listen((data) {
      final editedMessage = CommunityMessageModel.fromJson(data);
      final roomId = editedMessage.roomId ?? _activeHostelId;

      if (roomId != null) {
        final currentMessages = _messagesCache[roomId] ?? [];
        final updatedMessages = currentMessages.map((m) {
          return m.id == editedMessage.id ? editedMessage : m;
        }).toList();

        _messagesCache[roomId] = updatedMessages;

        if (roomId == _activeHostelId && state is CommunityLoaded) {
          emit((state as CommunityLoaded).copyWith(messages: updatedMessages));
        }
      }
    });

    _messageDeletedSubscription?.cancel();
    _messageDeletedSubscription = _socketService.messageDeletedStream.listen((data) {
      final roomId = data['roomId']?.toString() ?? _activeHostelId;
      final deletedId = data['id']?.toString() ?? '';

      if (roomId != null) {
        final currentMessages = _messagesCache[roomId] ?? [];
        final updatedMessages = currentMessages.map((m) {
          if (m.id == deletedId) {
            return CommunityMessageModel(
              id: m.id,
              senderId: m.senderId,
              senderName: m.senderName,
              text: '',
              createdAt: m.createdAt,
              isMe: m.isMe,
              senderAvatar: m.senderAvatar,
              roomId: m.roomId,
              type: m.type,
              isSystem: m.isSystem,
              isEdited: m.isEdited,
              isDeleted: true,
            );
          }
          return m;
        }).toList();

        _messagesCache[roomId] = updatedMessages;

        if (roomId == _activeHostelId && state is CommunityLoaded) {
          emit((state as CommunityLoaded).copyWith(messages: updatedMessages));
        }
      }
    });
  }

  Future<void> loadCommunityData(String hostelId) async {
    if (isClosed) return;

    _activeHostelId = hostelId;

    if (_messagesCache.containsKey(hostelId)) {
      emit(
        CommunityLoaded(
          details: _detailsCache[hostelId],
          messages: _messagesCache[hostelId]!,
          announcements: _announcementsCache[hostelId] ?? [],
          discussions: _discussionsCache[hostelId] ?? [],
          hasMoreMessages: _hasMoreMessagesCache[hostelId] ?? true,
        ),
      );
    } else {
      emit(CommunityLoading());
    }

    try {
      final results = await Future.wait([
        _getDetails(hostelId),
        _getMessages(hostelId, limit: 50),
        _getAnnouncements(hostelId),
        _getDiscussions(hostelId),
      ]);

      if (isClosed) return;

      final details = results[0] as CommunityDetailsEntity;
      final messages = results[1] as List<CommunityMessageEntity>;
      final announcements = results[2] as List<AnnouncementEntity>;
      final discussions = results[3] as List<OwnerDiscussionEntity>;

      _detailsCache[hostelId] = details;
      _messagesCache[hostelId] = messages;
      _announcementsCache[hostelId] = announcements;
      _discussionsCache[hostelId] = discussions;
      _hasMoreMessagesCache[hostelId] = messages.length >= 50;

      if (_activeHostelId == hostelId) {
        emit(
          CommunityLoaded(
            details: details,
            messages: messages,
            announcements: announcements,
            discussions: discussions,
            hasMoreMessages: _hasMoreMessagesCache[hostelId]!,
          ),
        );
      }
    } catch (e) {
      AppLogger.error('loadCommunityData failed', e);

      if (_activeHostelId == hostelId &&
          !_messagesCache.containsKey(hostelId)) {
        emit(CommunityError(message: ErrorHelper.toFriendlyMessage(e)));
      }
    }
  }

  Future<void> refreshMessages(String hostelId) async {
    try {
      final messages = await _getMessages(hostelId, limit: 50);
      _messagesCache[hostelId] = messages;

      if (_activeHostelId == hostelId && state is CommunityLoaded) {
        emit((state as CommunityLoaded).copyWith(messages: messages));
      }
    } catch (e) {
      AppLogger.error('refreshMessages failed', e);
    }
  }

  Future<void> loadOlderMessages(String hostelId) async {
    final s = state;
    if (s is! CommunityLoaded || !s.hasMoreMessages || s.isLoadingMoreMessages) {
      return;
    }

    emit(s.copyWith(isLoadingMoreMessages: true));
    try {
      final oldestId = s.messages.isNotEmpty ? s.messages.first.id : null;
      final older = await _getMessages(hostelId, limit: 50, before: oldestId);

      if (isClosed) return;

      final updatedMessages = [...older, ..._messagesCache[hostelId]!];
      _messagesCache[hostelId] = updatedMessages;
      _hasMoreMessagesCache[hostelId] = older.length >= 50;

      if (_activeHostelId == hostelId) {
        emit(
          s.copyWith(
            messages: updatedMessages,
            hasMoreMessages: _hasMoreMessagesCache[hostelId]!,
            isLoadingMoreMessages: false,
          ),
        );
      }
    } catch (e) {
      AppLogger.error('loadOlderMessages failed', e);
      if (_activeHostelId == hostelId && state is CommunityLoaded) {
        emit((state as CommunityLoaded).copyWith(isLoadingMoreMessages: false));
      }
    }
  }

  Future<void> joinCommunity(String hostelId, String userId) async {
    _activeHostelId = hostelId;
    _socketService.joinCommunity(hostelId, userId);
  }

  Future<void> leaveCommunity() async {}

  Future<void> sendMessage(
    String hostelId,
    String text, {
    String? senderId,
    String? senderName,
    String? senderAvatar,
  }) async {
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final optimisticMessage = CommunityMessageEntity(
      id: tempId,
      senderId: senderId ?? '',
      senderName: senderName ?? 'You',
      senderAvatar: senderAvatar,
      text: text,
      roomId: hostelId,
      createdAt: DateTime.now(),
      type: 'TEXT',
      isMe: true,
    );

    if (state is CommunityLoaded) {
      final s = state as CommunityLoaded;
      final updatedMessages = [...s.messages, optimisticMessage];
      _messagesCache[hostelId] = updatedMessages;
      emit(s.copyWith(messages: updatedMessages));
    }

    try {
      await _sendMessage(hostelId, text);
    } catch (e) {
      AppLogger.error('sendMessage failed', e);
      if (state is CommunityLoaded) {
        final s = state as CommunityLoaded;
        final rolledBack = s.messages.where((m) => m.id != tempId).toList();
        _messagesCache[hostelId] = rolledBack;
        emit(s.copyWith(messages: rolledBack));
      }
    }
  }

  Future<void> editMessage(String messageId, String newText) async {
    final currentState = state;
    if (currentState is! CommunityLoaded || newText.trim().isEmpty || _activeHostelId == null) return;

    final currentMessages = List<CommunityMessageEntity>.from(currentState.messages);
    final index = currentMessages.indexWhere((m) => m.id == messageId);
    CommunityMessageEntity? oldMessage;
    
    if (index != -1) {
      oldMessage = currentMessages[index];
      final optimisticMessage = CommunityMessageEntity(
        id: oldMessage.id,
        senderId: oldMessage.senderId,
        senderName: oldMessage.senderName,
        text: newText,
        createdAt: oldMessage.createdAt,
        isMe: oldMessage.isMe,
        senderAvatar: oldMessage.senderAvatar,
        roomId: oldMessage.roomId,
        type: oldMessage.type,
        isSystem: oldMessage.isSystem,
        isEdited: true,
        isDeleted: oldMessage.isDeleted,
      );
      currentMessages[index] = optimisticMessage;
      _messagesCache[_activeHostelId!] = currentMessages;
      emit(currentState.copyWith(messages: currentMessages));
    }

    try {
      await _editMessage(_activeHostelId!, messageId, newText);
    } catch (e) {
      AppLogger.error('editMessage failed', e);
      if (oldMessage != null && state is CommunityLoaded) {
        final fallbackState = state as CommunityLoaded;
        final fallbackMessages = List<CommunityMessageEntity>.from(fallbackState.messages);
        final fallbackIndex = fallbackMessages.indexWhere((m) => m.id == messageId);
        if (fallbackIndex != -1) {
          fallbackMessages[fallbackIndex] = oldMessage;
          _messagesCache[_activeHostelId!] = fallbackMessages;
          emit(fallbackState.copyWith(messages: fallbackMessages));
        }
      }
    }
  }

  Future<void> deleteMessage(String messageId) async {
    final currentState = state;
    if (currentState is! CommunityLoaded || _activeHostelId == null) return;

    final currentMessages = List<CommunityMessageEntity>.from(currentState.messages);
    final index = currentMessages.indexWhere((m) => m.id == messageId);
    CommunityMessageEntity? oldMessage;

    if (index != -1) {
      oldMessage = currentMessages[index];
      final optimisticMessage = CommunityMessageEntity(
        id: oldMessage.id,
        senderId: oldMessage.senderId,
        senderName: oldMessage.senderName,
        text: '',
        createdAt: oldMessage.createdAt,
        isMe: oldMessage.isMe,
        senderAvatar: oldMessage.senderAvatar,
        roomId: oldMessage.roomId,
        type: oldMessage.type,
        isSystem: oldMessage.isSystem,
        isEdited: oldMessage.isEdited,
        isDeleted: true,
      );
      currentMessages[index] = optimisticMessage;
      _messagesCache[_activeHostelId!] = currentMessages;
      emit(currentState.copyWith(messages: currentMessages));
    }

    try {
      await _deleteMessage(_activeHostelId!, messageId);
    } catch (e) {
      AppLogger.error('deleteMessage failed', e);
      if (oldMessage != null && state is CommunityLoaded) {
        final fallbackState = state as CommunityLoaded;
        final fallbackMessages = List<CommunityMessageEntity>.from(fallbackState.messages);
        final fallbackIndex = fallbackMessages.indexWhere((m) => m.id == messageId);
        if (fallbackIndex != -1) {
          fallbackMessages[fallbackIndex] = oldMessage;
          _messagesCache[_activeHostelId!] = fallbackMessages;
          emit(fallbackState.copyWith(messages: fallbackMessages));
        }
      }
    }
  }

  Future<void> sendImageMessage(
    String hostelId,
    String imagePath, {
    String? senderId,
    String? senderName,
    String? senderAvatar,
  }) async {
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final optimisticMessage = CommunityMessageEntity(
      id: tempId,
      senderId: senderId ?? '',
      senderName: senderName ?? 'You',
      senderAvatar: senderAvatar,
      imageUrl: imagePath,
      roomId: hostelId,
      createdAt: DateTime.now(),
      type: 'IMAGE',
      isMe: true,
    );

    if (state is CommunityLoaded) {
      final s = state as CommunityLoaded;
      final updatedMessages = [...s.messages, optimisticMessage];
      _messagesCache[hostelId] = updatedMessages;
      emit(s.copyWith(messages: updatedMessages));
    }

    try {
      await _sendImage(hostelId, imagePath);
    } catch (e) {
      AppLogger.error('sendImageMessage failed', e);
      if (state is CommunityLoaded) {
        final s = state as CommunityLoaded;
        final rolledBack = s.messages.where((m) => m.id != tempId).toList();
        _messagesCache[hostelId] = rolledBack;
        emit(s.copyWith(messages: rolledBack));
      }
    }
  }

  Future<void> postAnnouncement(
    String hostelId,
    String title,
    String content,
  ) async {
    try {
      await _postAnnouncement(hostelId, title, content);
      final announcements = await _getAnnouncements(hostelId);
      _announcementsCache[hostelId] = announcements;

      if (_activeHostelId == hostelId && state is CommunityLoaded) {
        emit((state as CommunityLoaded).copyWith(announcements: announcements));
      }
    } catch (e) {
      AppLogger.error('postAnnouncement failed', e);
    }
  }

  Future<void> createDiscussion({
    required String title,
    required String description,
    required String type,
    String? hostelId,
  }) async {
    if (hostelId == null) return;
    try {
      await _createDiscussion(
        title: title,
        description: description,
        type: type,
        hostelId: hostelId,
      );
      final discussions = await _getDiscussions(hostelId);
      _discussionsCache[hostelId] = discussions;

      if (_activeHostelId == hostelId && state is CommunityLoaded) {
        emit((state as CommunityLoaded).copyWith(discussions: discussions));
      }
    } catch (e) {
      AppLogger.error('createDiscussion failed', e);
    }
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    _messageEditedSubscription?.cancel();
    _messageDeletedSubscription?.cancel();
    return super.close();
  }
}
