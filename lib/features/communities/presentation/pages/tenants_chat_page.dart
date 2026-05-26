import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/communities/presentation/cubit/community_cubit.dart';

import 'package:stayindia_owner/features/communities/domain/entities/community_entity.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stayindia_owner/features/communities/presentation/widgets/chat_message_bubble.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:stayindia_owner/core/utils/image_compressor.dart';
import 'package:stayindia_owner/features/communities/presentation/pages/community_detail_page.dart';

class TenantsChatPage extends StatelessWidget {
  final String hostelId;
  final String? communityName;
  final String? communityIcon;
  final String? communityDescription;
  final bool isOwnerChat;
  final String? status;

  const TenantsChatPage({
    super.key,
    required this.hostelId,
    this.communityName,
    this.communityIcon,
    this.communityDescription,
    this.isOwnerChat = false,
    this.status,
  });

  @override
  Widget build(BuildContext context) {
    return const _TenantsChatView();
  }
}

class _TenantsChatView extends StatefulWidget {
  const _TenantsChatView();

  @override
  State<_TenantsChatView> createState() => _TenantsChatViewState();
}

class _TenantsChatViewState extends State<_TenantsChatView> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  String? _editingMessageId;

  final Set<String> _selectedMessageIds = {};
  final Set<String> _starredMessageIds = {};
  final Map<String, String> _reactions = {}; // messageId -> emoji
  CommunityMessageEntity? _replyingToMessage;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStarredMessages();
      final cubit = context.read<CommunityCubit>();
      final ownerId = context.read<AuthCubit>().currentOwner?.id;
      final page = context.findAncestorWidgetOfExactType<TenantsChatPage>()!;

      if (ownerId != null) {
        cubit.loadCommunityData(page.hostelId);
        cubit.joinCommunity(page.hostelId, ownerId);
      }
    });

    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadStarredMessages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final page = context.findAncestorWidgetOfExactType<TenantsChatPage>()!;
      final List<String>? starred = prefs.getStringList('starred_messages_${page.hostelId}');
      if (starred != null) {
        setState(() {
          _starredMessageIds.addAll(starred);
        });
      }
    } catch (_) {}
  }

  Future<void> _toggleStarSelectedMessages() async {
    final page = context.findAncestorWidgetOfExactType<TenantsChatPage>()!;
    bool allStarred = _selectedMessageIds.every((id) => _starredMessageIds.contains(id));
    setState(() {
      if (allStarred) {
        _starredMessageIds.removeAll(_selectedMessageIds);
      } else {
        _starredMessageIds.addAll(_selectedMessageIds);
      }
      _selectedMessageIds.clear();
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('starred_messages_${page.hostelId}', _starredMessageIds.toList());
    } catch (_) {}
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(allStarred ? "Messages unstarred" : "Messages starred"),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getCleanTextMessage(String text) {
    final prefix = 'REPLY_TO_MSG:';
    if (text.startsWith(prefix)) {
      final body = text.substring(prefix.length);
      final parts = body.split('::REPLY_TO_MSG:');
      if (parts.length >= 2) {
        return parts.sublist(1).join('::REPLY_TO_MSG:');
      }
    }
    return text;
  }

  void _copySelectedMessages(List<CommunityMessageEntity> allMessages) {
    final selected = allMessages.where((m) => _selectedMessageIds.contains(m.id)).toList();
    selected.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final texts = selected.map((m) {
      final cleanText = _getCleanTextMessage(m.text);
      return "${m.senderName}: $cleanText";
    }).join('\n');

    Clipboard.setData(ClipboardData(text: texts));
    setState(() {
      _selectedMessageIds.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Copied to clipboard"),
        duration: Duration(seconds: 2),
      ),
    );
  }


  void _reactToMessage(String messageId, String emoji) {
    setState(() {
      if (_reactions[messageId] == emoji) {
        _reactions.remove(messageId); // tap same emoji = remove
      } else {
        _reactions[messageId] = emoji;
      }
    });
  }

  void _onScroll() {
    if (_scrollController.hasClients && _scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 40) {
      final page = context.findAncestorWidgetOfExactType<TenantsChatPage>()!;
      context.read<CommunityCubit>().loadOlderMessages(page.hostelId);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }



  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      final page = context.findAncestorWidgetOfExactType<TenantsChatPage>()!;
      final owner = context.read<AuthCubit>().currentOwner;

      if (_editingMessageId != null) {
        final communityState = context.read<CommunityCubit>().state;
        final messages = communityState is CommunityLoaded ? communityState.messages : <CommunityMessageEntity>[];
        final originalMsg = messages.firstWhere((m) => m.id == _editingMessageId);
        String editedText = text;
        
        final prefix = 'REPLY_TO_MSG:';
        if (originalMsg.text.startsWith(prefix)) {
          final body = originalMsg.text.substring(prefix.length);
          final parts = body.split('::REPLY_TO_MSG:');
          if (parts.length >= 2) {
            final header = parts[0];
            editedText = 'REPLY_TO_MSG:$header::REPLY_TO_MSG:$text';
          }
        }
        
        context.read<CommunityCubit>().editMessage(_editingMessageId!, editedText);
        setState(() {
          _editingMessageId = null;
        });
      } else {
        String sentText = text;
        if (_replyingToMessage != null) {
          final cleanText = _getCleanTextMessage(_replyingToMessage!.text);
          sentText = 'REPLY_TO_MSG:${_replyingToMessage!.senderName}::${cleanText.replaceAll('\n', ' ')}::REPLY_TO_MSG:$text';
          setState(() {
            _replyingToMessage = null;
          });
        }
        context.read<CommunityCubit>().sendMessage(
          page.hostelId,
          sentText,
          senderId: owner?.id,
          senderName: owner?.name,
          senderAvatar: owner?.avatar,
        );
        _scrollToBottom();
      }
      _controller.clear();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients && _scrollController.offset > 0) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _pickAndSendImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Compressing and sending image...')),
      );

      final compressedFile = await ImageCompressor.compressImage(
        File(image.path),
      );
      if (compressedFile != null) {
        if (!mounted) return;
        final page = context.findAncestorWidgetOfExactType<TenantsChatPage>()!;
        final owner = context.read<AuthCubit>().currentOwner;

        context.read<CommunityCubit>().sendImageMessage(
          page.hostelId,
          compressedFile.path,
          senderId: owner?.id,
          senderName: owner?.name,
          senderAvatar: owner?.avatar,
        );
        _scrollToBottom();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = context.findAncestorWidgetOfExactType<TenantsChatPage>()!;
    final isPending = page.status?.toUpperCase() == 'PENDING';
    final communityState = context.watch<CommunityCubit>().state;
    final allMessages = communityState is CommunityLoaded ? communityState.messages : <CommunityMessageEntity>[];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _selectedMessageIds.isNotEmpty
          ? _buildSelectionAppBar(context, allMessages)
          : _buildAppBar(context, page),
      body: isPending
          ? Center(
              child: Padding(
                padding: EdgeInsets.all(32.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(24.w),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.pending_actions_rounded,
                        size: 64.sp,
                        color: Colors.orange.shade700,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Verification Pending',
                      style: GoogleFonts.outfit(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkText,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'Your community is currently under review by our executive team. Once verified, chat and media sharing features will be instantly enabled.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 15.sp,
                        color: AppColors.greyText,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Stack(
              children: [
                Positioned.fill(
                  child: const CustomPaint(
                    painter: ChatWallpaperPainter(),
                  ),
                ),
                Column(
                  children: [
                    Expanded(
                      child: BlocBuilder<CommunityCubit, CommunityState>(
                    builder: (context, state) {
                      if (state is CommunityLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (state is CommunityLoaded) {
                        final messages = state.messages;

                        if (messages.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 64.sp,
                                  color: Colors.grey.shade300,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  'No messages yet',
                                  style: GoogleFonts.outfit(
                                    fontSize: 16.sp,
                                    color: AppColors.greyText,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final reversedMessages = messages.reversed.toList();
                        final itemCount = reversedMessages.length + 1;
                        return ListView.builder(
                          reverse: true,
                          controller: _scrollController,
                          padding: EdgeInsets.all(20.w),
                          itemCount: itemCount,
                          itemBuilder: (context, index) {
                            if (index == itemCount - 1) {
                              if (state.isLoadingMoreMessages) {
                                return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  child: Center(
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              if (!state.hasMoreMessages) {
                                return Padding(
                                  padding: EdgeInsets.symmetric(vertical: 8),
                                  child: Center(
                                    child: Text(
                                      ' Beginning of conversation',
                                      style: GoogleFonts.outfit(
                                        fontSize: 12.sp,
                                        color: AppColors.greyText,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            }

                            final message = reversedMessages[index];

                            final owner = context
                                .read<AuthCubit>()
                                .currentOwner;
                            final currentOwnerId = owner?.id;

                            final isMe =
                                (currentOwnerId != null &&
                                message.senderId.isNotEmpty &&
                                message.senderId == currentOwnerId);

                            final updatedMessage = CommunityMessageEntity(
                              id: message.id,
                              senderId: message.senderId,
                              senderName: message.senderName,
                              senderAvatar: message.senderAvatar,
                              text: message.text,
                              imageUrl: message.imageUrl,
                              roomId: message.roomId,
                              createdAt: message.createdAt,
                              type: message.type,
                              isSystem: message.isSystem,
                              isMe: isMe,
                              reaction: _reactions[message.id],
                            );

                            final isSelected = _selectedMessageIds.contains(updatedMessage.id);
                            final isSelectionMode = _selectedMessageIds.isNotEmpty;
                            final isStarred = _starredMessageIds.contains(updatedMessage.id);

                            return SwipeToReply(
                              enabled: !isSelectionMode && !updatedMessage.isDeleted,
                              onSwipe: () {
                                setState(() {
                                  _replyingToMessage = updatedMessage;
                                });
                                _focusNode.requestFocus();
                              },
                              child: ChatMessageBubble(
                                message: updatedMessage,
                                isSelected: isSelected,
                                isSelectionMode: isSelectionMode,
                                isStarred: isStarred,
                                onReact: !isSelectionMode && !updatedMessage.isDeleted
                                    ? (emoji) => _reactToMessage(updatedMessage.id, emoji)
                                    : null,
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      _selectedMessageIds.remove(updatedMessage.id);
                                    } else {
                                      _selectedMessageIds.add(updatedMessage.id);
                                    }
                                  });
                                },
                                onLongPressStart: isSelectionMode
                                    ? (details) {
                                        if (!updatedMessage.isDeleted) {
                                          setState(() {
                                            _selectedMessageIds.add(updatedMessage.id);
                                          });
                                        }
                                      }
                                    : null,
                              ),
                            );
                          },
                        );
                      }
                      if (state is CommunityError) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.w),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline_rounded,
                                  size: 48.sp,
                                  color: Colors.red.shade300,
                                ),
                                SizedBox(height: 16.h),
                                Text(
                                  state.message,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    color: AppColors.greyText,
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                ElevatedButton(
                                  onPressed: () {
                                    final page = context
                                        .findAncestorWidgetOfExactType<
                                          TenantsChatPage
                                        >()!;
                                    context
                                        .read<CommunityCubit>()
                                        .loadCommunityData(page.hostelId);
                                  },
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                _buildInputSection(page),
              ],
            ),
          ],
        ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, TenantsChatPage page) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      leading: BouncingWrapper(
        onTap: () => Navigator.pop(context),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.black,
          size: 20,
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10.r),
              image: page.communityIcon != null
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(page.communityIcon!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: page.communityIcon == null
                ? Icon(
                    Icons.groups_rounded,
                    color: AppColors.primaryBlue,
                    size: 20.sp,
                  )
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  page.communityName ?? 'Tenants Community',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    color: AppColors.darkText,
                    fontWeight: FontWeight.w800,
                    fontSize: 16.sp,
                  ),
                ),
                if (page.isOwnerChat)
                  Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: Text(
                      page.status?.toUpperCase() == 'PENDING'
                          ? 'Verification Pending ⏳'
                          : 'Verified National Network',
                      style: GoogleFonts.outfit(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: page.status?.toUpperCase() == 'PENDING'
                            ? Colors.orange.shade700
                            : AppColors.primaryBlue,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (page.isOwnerChat)
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: BouncingWrapper(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CommunityDetailPage(communityId: page.hostelId),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.primaryBlue,
                  size: 22.sp,
                ),
              ),
            ),
          ),
      ],
    );
  }

  PreferredSizeWidget _buildSelectionAppBar(BuildContext context, List<CommunityMessageEntity> allMessages) {
    final selected = allMessages.where((m) => _selectedMessageIds.contains(m.id)).toList();
    final isOne = selected.length == 1;
    final owner = context.read<AuthCubit>().currentOwner;
    final currentOwnerId = owner?.id;
    final isOneMe = isOne &&
        currentOwnerId != null &&
        selected.first.senderId.isNotEmpty &&
        selected.first.senderId == currentOwnerId;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: Colors.black),
        onPressed: () {
          setState(() {
            _selectedMessageIds.clear();
          });
        },
      ),
      title: Text(
        '${_selectedMessageIds.length}',
        style: GoogleFonts.outfit(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 20.sp,
        ),
      ),
      actions: [
        if (isOne)
          IconButton(
            icon: const Icon(Icons.reply_rounded, color: Colors.black),
            onPressed: () {
              setState(() {
                _replyingToMessage = selected.first;
                _selectedMessageIds.clear();
              });
              _focusNode.requestFocus();
            },
          ),
        if (isOneMe)
          IconButton(
            icon: const Icon(Icons.edit_rounded, color: Colors.black),
            onPressed: () {
              setState(() {
                _editingMessageId = selected.first.id;
                _controller.text = _getCleanTextMessage(selected.first.text);
                _selectedMessageIds.clear();
              });
              _focusNode.requestFocus();
            },
          ),
        IconButton(
          icon: Icon(
            _selectedMessageIds.every((id) => _starredMessageIds.contains(id))
                ? Icons.star_border_rounded
                : Icons.star_rounded,
            color: Colors.black,
          ),
          onPressed: _toggleStarSelectedMessages,
        ),
        IconButton(
          icon: const Icon(Icons.delete_rounded, color: Colors.black),
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: Text('Delete message(s)', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                content: Text('Are you sure you want to delete these message(s)?', style: GoogleFonts.outfit()),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Cancel', style: GoogleFonts.outfit(color: AppColors.greyText)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
                      Navigator.pop(ctx);
                      for (var id in _selectedMessageIds) {
                        context.read<CommunityCubit>().deleteMessage(id);
                      }
                      setState(() {
                        _selectedMessageIds.clear();
                      });
                    },
                    child: Text('Delete', style: GoogleFonts.outfit(color: Colors.white)),
                  ),
                ],
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.copy_rounded, color: Colors.black),
          onPressed: () => _copySelectedMessages(allMessages),
        ),
      ],
    );
  }

  Widget _buildInputSection(TenantsChatPage page) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_editingMessageId != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              margin: EdgeInsets.only(bottom: 8.h),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  const Icon(Icons.edit_rounded, color: AppColors.primaryBlue, size: 16),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Editing Message',
                      style: GoogleFonts.outfit(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500,
                        fontSize: 12.sp,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _editingMessageId = null;
                        _controller.clear();
                      });
                    },
                    child: const Icon(Icons.close_rounded, color: AppColors.primaryBlue, size: 18),
                  ),
                ],
              ),
            ),
          if (_replyingToMessage != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              margin: EdgeInsets.only(bottom: 8.h),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 4.w,
                    height: 32.h,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _replyingToMessage!.senderName,
                          style: GoogleFonts.outfit(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          _getCleanTextMessage(_replyingToMessage!.text),
                          style: GoogleFonts.outfit(
                            color: Colors.grey.shade600,
                            fontSize: 12.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _replyingToMessage = null;
                      });
                    },
                    child: const Icon(Icons.close_rounded, color: AppColors.primaryBlue, size: 18),
                  ),
                ],
              ),
            ),
          Row(
            children: [
          if (page.isOwnerChat) ...[
            BouncingWrapper(
              onTap: _pickAndSendImage,
              child: Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.add_photo_alternate_rounded,
                  color: AppColors.primaryBlue,
                  size: 20,
                ),
              ),
            ),
            SizedBox(width: 12.w),
          ],
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: GoogleFonts.outfit(fontSize: 15.sp),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: GoogleFonts.outfit(color: Colors.grey.shade500),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          BouncingWrapper(
            onTap: _sendMessage,
            child: Container(
              padding: EdgeInsets.all(12.w),
              decoration: const BoxDecoration(
                color: AppColors.primaryBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      ],
      ),
    );
  }
}

class ChatWallpaperPainter extends CustomPainter {
  const ChatWallpaperPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paintColor = Colors.black.withValues(alpha: 0.045); // subtle background icons

    final icons = [
      Icons.chat_bubble_outline_rounded,
      Icons.local_phone_outlined,
      Icons.camera_alt_outlined,
      Icons.music_note_outlined,
      Icons.favorite_border_rounded,
      Icons.sentiment_satisfied_alt_outlined,
      Icons.coffee_outlined,
      Icons.lightbulb_outline_rounded,
      Icons.star_border_rounded,
      Icons.wb_sunny_outlined,
      Icons.directions_bike_outlined,
      Icons.umbrella_outlined,
      Icons.photo_outlined,
      Icons.pets_outlined,
      Icons.cloud_queue_rounded,
      Icons.explore_outlined,
      Icons.brush_outlined,
      Icons.headset_mic_outlined,
      Icons.anchor_outlined,
      Icons.watch_later_outlined,
      Icons.sailing_outlined,
      Icons.flight_outlined,
      Icons.cake_outlined,
      Icons.edit_outlined,
    ];

    const double gridStep = 55.0; // high-density WhatsApp layout
    int rowIndex = 0;

    for (double y = 25.0; y < size.height; y += gridStep) {
      final double xStart = (rowIndex % 2 == 0) ? 25.0 : 25.0 + (gridStep / 2);
      for (double x = xStart; x < size.width; x += gridStep) {
        final int seed = (x.toInt() * 7 + y.toInt() * 13).abs();
        
        final icon = icons[seed % icons.length];
        
        final double angleDegrees = ((seed % 90) - 45).toDouble();
        final double angleRadians = angleDegrees * 3.141592653589793 / 180.0;
        
        final double fontSize = 15.0 + (seed % 8);
        
        final double jitterX = ((seed % 20) - 10).toDouble();
        final double jitterY = (((seed >> 2) % 20) - 10).toDouble();

        final textPainter = TextPainter(
          textDirection: TextDirection.ltr,
          text: TextSpan(
            text: String.fromCharCode(icon.codePoint),
            style: TextStyle(
              fontSize: fontSize,
              fontFamily: icon.fontFamily,
              package: icon.fontPackage,
              color: paintColor,
            ),
          ),
        );
        
        textPainter.layout();
        
        canvas.save();
        canvas.translate(x + jitterX, y + jitterY);
        canvas.rotate(angleRadians);
        
        textPainter.paint(
          canvas,
          Offset(-textPainter.width / 2, -textPainter.height / 2),
        );
        
        canvas.restore();
      }
      rowIndex++;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SwipeToReply extends StatefulWidget {
  final Widget child;
  final VoidCallback onSwipe;
  final bool enabled;

  const SwipeToReply({
    super.key,
    required this.child,
    required this.onSwipe,
    this.enabled = true,
  });

  @override
  State<SwipeToReply> createState() => _SwipeToReplyState();
}

class _SwipeToReplyState extends State<SwipeToReply> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  double _dragOffset = 0.0;
  bool _swipedTriggered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return widget.child;

    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx > 0) {
          setState(() {
            _dragOffset = (_dragOffset + details.delta.dx).clamp(0.0, 70.0);
          });
          if (_dragOffset >= 50.0 && !_swipedTriggered) {
            _swipedTriggered = true;
          }
        } else if (details.delta.dx < 0 && _dragOffset > 0) {
          setState(() {
            _dragOffset = (_dragOffset + details.delta.dx).clamp(0.0, 70.0);
          });
        }
      },
      onHorizontalDragEnd: (details) {
        if (_dragOffset >= 50.0) {
          widget.onSwipe();
        }
        _swipedTriggered = false;
        final start = _dragOffset;
        final double end = 0.0;
        _controller.reset();
        final animation = Tween<double>(begin: start, end: end).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOut),
        );
        animation.addListener(() {
          setState(() {
            _dragOffset = animation.value;
          });
        });
        _controller.forward();
      },
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 12,
            top: 0,
            bottom: 0,
            child: Center(
              child: Opacity(
                opacity: (_dragOffset / 50.0).clamp(0.0, 1.0),
                child: const Icon(
                  Icons.reply_rounded,
                  color: Colors.grey,
                  size: 22,
                ),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(_dragOffset, 0.0),
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
