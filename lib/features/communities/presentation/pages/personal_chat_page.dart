import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dio/dio.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/injection_container.dart';
import 'package:stayindia_owner/core/socket/socket_service.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stayindia_owner/features/communities/presentation/pages/tenants_chat_page.dart' show ChatWallpaperPainter;
import 'dart:async';

class PersonalChatPage extends StatefulWidget {
  final String chatId;
  final String otherUserName;
  final String otherUserAvatar;
  final bool isOnline;

  const PersonalChatPage({
    super.key,
    required this.chatId,
    required this.otherUserName,
    required this.otherUserAvatar,
    this.isOnline = false,
  });

  @override
  State<PersonalChatPage> createState() => _PersonalChatPageState();
}

class _PersonalChatPageState extends State<PersonalChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  final List<Map<String, dynamic>> _messages = [];
  bool _isLoading = true;
  StreamSubscription? _socketSubscription;
  StreamSubscription? _messageEditedSub;
  Timer? _presenceTimer;
  late bool _isOnline;
  String? _editingMessageId;
  String? _selectedMessageId;

  @override
  void initState() {
    super.initState();
    _isOnline = widget.isOnline;
    _fetchMessageHistory();
    _initSocketListener();
    _startPresenceCheck();
  }

  @override
  void dispose() {
    _presenceTimer?.cancel();
    _socketSubscription?.cancel();
    _messageEditedSub?.cancel();
    sl<SocketService>().leaveCommunity(widget.chatId);
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _startPresenceCheck() {
    _fetchPresenceStatus();
    _presenceTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _fetchPresenceStatus();
    });
  }

  Future<void> _fetchPresenceStatus() async {
    try {
      final dio = sl<Dio>();
      final response = await dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.ownerCommunities}/personal-chat/presence/${widget.chatId}',
      );
      if (response.statusCode == 200) {
        final onlineStatus = response.data['isOnline'] as bool? ?? false;
        if (mounted && _isOnline != onlineStatus) {
          setState(() {
            _isOnline = onlineStatus;
          });
        }
      }
    } catch (e) {
      debugPrint('Error fetching presence status: $e');
    }
  }

  void _initSocketListener() {
    final owner = context.read<AuthCubit>().currentOwner;
    if (owner != null) {
      sl<SocketService>().joinCommunity(widget.chatId, owner.id);
    }

    _socketSubscription = sl<SocketService>().messageStream.listen((data) {
      final roomId = data['roomId'] ?? data['community'];
      if (roomId == widget.chatId) {
        if (mounted) {
          setState(() {
            final exists = _messages.any((m) => m['_id'] == data['_id'] || (m['isTemp'] == true && m['text'] == data['text']));
            if (!exists) {
              _messages.add(data);
              _scrollToBottom();
            } else {
              final idx = _messages.indexWhere((m) => m['isTemp'] == true && m['text'] == data['text']);
              if (idx != -1) {
                _messages[idx] = data;
              }
            }
          });
        }
      }
    });

    _messageEditedSub = sl<SocketService>().messageEditedStream.listen((data) {
      final roomId = data['roomId'] ?? data['community'];
      if (roomId == widget.chatId) {
        if (mounted) {
          setState(() {
            final idx = _messages.indexWhere((m) => m['_id'] == data['_id']);
            if (idx != -1) {
              _messages[idx] = Map<String, dynamic>.from(_messages[idx]);
              _messages[idx]['text'] = data['text'];
              _messages[idx]['isEdited'] = data['isEdited'] ?? true;
            }
          });
        }
      }
    });
  }

  Future<void> _fetchMessageHistory() async {
    try {
      final dio = sl<Dio>();
      final response = await dio.get('${ApiConstants.baseUrl}${ApiConstants.communityChat(widget.chatId)}/messages');
      if (response.statusCode == 200) {
        final List<dynamic> fetched =
            response.data['data']?['messages'] ?? response.data['messages'] ?? [];
        if (mounted) {
          setState(() {
            _messages.clear();
            _messages.addAll(List<Map<String, dynamic>>.from(fetched));
            _isLoading = false;
          });
          _scrollToBottom();
        }
        return;
      }
    } catch (e) {
      debugPrint('Error fetching personal messages: $e');
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();

    if (_editingMessageId != null) {
      final msgId = _editingMessageId!;
      final oldText = _messages.firstWhere((m) => m['_id'] == msgId)['text'] ?? '';
      
      setState(() {
        final idx = _messages.indexWhere((m) => m['_id'] == msgId);
        if (idx != -1) {
          _messages[idx] = Map<String, dynamic>.from(_messages[idx]);
          _messages[idx]['text'] = text;
          _messages[idx]['isEdited'] = true;
        }
        _editingMessageId = null;
      });

      try {
        final dio = sl<Dio>();
        final response = await dio.patch(
          '${ApiConstants.baseUrl}${ApiConstants.communityChat(widget.chatId)}/message/$msgId',
          data: {'text': text},
        );
        if (response.statusCode == 200) {
          return;
        }
      } catch (e) {
        debugPrint('Error editing message: $e');
        if (mounted) {
          setState(() {
            final idx = _messages.indexWhere((m) => m['_id'] == msgId);
            if (idx != -1) {
              _messages[idx] = Map<String, dynamic>.from(_messages[idx]);
              _messages[idx]['text'] = oldText;
            }
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to edit message.')),
          );
        }
      }
      return;
    }

    final owner = context.read<AuthCubit>().currentOwner;
    final tempId = 'temp_${DateTime.now().millisecondsSinceEpoch}';

    final optimisticMessage = {
      '_id': tempId,
      'sender': owner?.id ?? '',
      'senderName': owner?.name ?? 'You',
      'text': text,
      'createdAt': DateTime.now().toIso8601String(),
      'isTemp': true,
    };

    setState(() {
      _messages.add(optimisticMessage);
    });
    _scrollToBottom();

    try {
      final dio = sl<Dio>();
      final response = await dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.community}/message',
        data: {'chatId': widget.chatId, 'text': text},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final newMsg = response.data['data'] ?? response.data;
        if (mounted) {
          setState(() {
            final idx = _messages.indexWhere((m) => m['_id'] == tempId);
            if (idx != -1) {
              _messages[idx] = Map<String, dynamic>.from(newMsg);
            }
          });
        }
        return;
      }
    } catch (e) {
      debugPrint('Error sending personal message: $e');
    }

    if (mounted) {
      setState(() {
        _messages.removeWhere((m) => m['_id'] == tempId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send message. Please retry.')),
      );
    }
  }

  void _reactToMessage(String messageId, String emoji) {
    if (mounted) {
      setState(() {
        final idx = _messages.indexWhere((m) => m['_id'] == messageId);
        if (idx != -1) {
          _messages[idx] = Map<String, dynamic>.from(_messages[idx]);
          _messages[idx]['reaction'] = emoji;
        }
      });
    }
  }

  void _toggleStarMessage(String messageId) {
    if (mounted) {
      setState(() {
        final idx = _messages.indexWhere((m) => m['_id'] == messageId);
        if (idx != -1) {
          _messages[idx] = Map<String, dynamic>.from(_messages[idx]);
          _messages[idx]['isStarred'] = !(_messages[idx]['isStarred'] ?? false);
        }
      });
    }
  }

  void _startEditingMessage(Map<String, dynamic> message) {
    if (mounted) {
      setState(() {
        _editingMessageId = message['_id'];
        _controller.text = message['text'] ?? '';
      });
      _focusNode.requestFocus();
    }
  }

  void _exitSelectionMode() {
    if (mounted) {
      setState(() {
        _selectedMessageId = null;
      });
    }
  }

  void _showDeleteConfirmationDialog(BuildContext context, String messageId) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
          title: Text(
            'Delete Message?',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
              color: AppColors.darkText,
            ),
          ),
          content: Text(
            'Are you sure you want to delete this message? This action cannot be undone.',
            style: GoogleFonts.outfit(
              fontSize: 14.sp,
              color: AppColors.greyText,
            ),
          ),
          actionsPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.sp,
                  color: AppColors.greyText,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _deleteMessage(messageId);
                _exitSelectionMode();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                elevation: 0,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
              ),
              child: Text(
                'Delete',
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteMessage(String messageId) async {
    final oldMsg = _messages.firstWhere((m) => m['_id'] == messageId, orElse: () => {});
    if (oldMsg.isEmpty) return;

    setState(() {
      _messages.removeWhere((m) => m['_id'] == messageId);
    });

    try {
      final dio = sl<Dio>();
      final response = await dio.delete(
        '${ApiConstants.baseUrl}${ApiConstants.communityChat(widget.chatId)}/message/$messageId',
      );
      if (response.statusCode == 200) {
        return;
      }
    } catch (e) {
      debugPrint('Error deleting message: $e');
      if (mounted) {
        setState(() {
          _messages.add(oldMsg);
          _messages.sort((a, b) => a['createdAt'].compareTo(b['createdAt']));
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete message.')),
        );
      }
    }
  }

  Widget _buildFloatingReactions(String messageId, bool isMe) {
    final emojis = ['👍', '❤️', '😂', '😲', '😢', '🙏', '🔥'];

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 250),
      tween: Tween<double>(begin: 0.0, end: 1.0),
      curve: Curves.easeOutBack,
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Opacity(
            opacity: value.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 6.h),
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: const Color(0xFF1F2C34),
          borderRadius: BorderRadius.circular(30.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...emojis.asMap().entries.map((entry) {
              final idx = entry.key;
              final emoji = entry.value;

              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 200 + (idx * 35)),
                tween: Tween<double>(begin: 0.0, end: 1.0),
                curve: Curves.easeOutBack,
                builder: (context, val, child) {
                  return Transform.scale(
                    scale: val,
                    child: child,
                  );
                },
                child: GestureDetector(
                  onTap: () {
                    _reactToMessage(messageId, emoji);
                    _exitSelectionMode();
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6.w),
                    child: Text(
                      emoji,
                      style: TextStyle(fontSize: 22.sp),
                    ),
                  ),
                ),
              );
            }),
            TweenAnimationBuilder<double>(
              duration: Duration(milliseconds: 200 + (emojis.length * 35)),
              tween: Tween<double>(begin: 0.0, end: 1.0),
              curve: Curves.easeOutBack,
              builder: (context, val, child) {
                return Transform.scale(
                  scale: val,
                  child: child,
                );
              },
              child: GestureDetector(
                onTap: () {
                  _showAllEmojisPicker(messageId);
                },
                child: Container(
                  margin: EdgeInsets.only(left: 6.w),
                  padding: EdgeInsets.all(4.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.add,
                    color: Colors.white70,
                    size: 16.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllEmojisPicker(String messageId) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      backgroundColor: Colors.white,
      builder: (bottomSheetContext) {
        final allEmojis = [
          '😀', '😃', '😄', '😁', '😆', '😅', '😂', '🤣', '😊', '😇',
          '🙂', '🙃', '😉', '😌', '😍', '🥰', '😘', '😗', '😙', '😚',
          '😋', '😛', '😝', '😜', '🤪', '🤨', '🧐', '🤓', '😎', '🥸',
          '🤩', '🥳', '😏', '😒', '😞', '😔', '😟', '😕', '🙁', '☹️',
          '😣', '😖', '😫', '😩', '🥺', '😢', '😭', '😤', '😠', '😡',
          '🤬', '🤯', '😳', '🥵', '🥶', '😱', '😨', '😰', '😥', '😓',
          '👋', '🤚', '🖐️', '✋', '🖖', '👌', '🤌', '🤏', '✌️', '🤞',
          '🤟', '🤘', '🤙', '👈', '👉', '👆', '🖕', '👇', '☝️', '👍',
          '👎', '✊', '👊', '🤛', '🤜', '👏', '🙌', '👐', '🤲', '🤝',
          '🙏', '✍️', '💅', '🤳', '💪', '🦾',
          '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍', '🤎', '💔',
          '❤️‍🔥', '❤️‍🩹', '❣️', '💕', '💞', '💓', '💗', '💖', '💘', '💝',
          '✨', '⭐', '🌟', '💫', '🔥', '💥', '💯', '🎉', '🎊', '🎈',
        ];

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          height: 380.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'React with...',
                style: GoogleFonts.outfit(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                ),
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    mainAxisSpacing: 10.h,
                    crossAxisSpacing: 10.w,
                  ),
                  itemCount: allEmojis.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final emoji = allEmojis[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(bottomSheetContext);
                        _reactToMessage(messageId, emoji);
                        _exitSelectionMode();
                      },
                      child: Center(
                        child: Text(
                          emoji,
                          style: TextStyle(fontSize: 26.sp),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showForwardDialog(String textToForward) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
              child: FutureBuilder<Response>(
                future: sl<Dio>().get('${ApiConstants.baseUrl}${ApiConstants.ownerCommunities}/personal-chat/list'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: 200.h,
                      child: const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
                    );
                  }
                  if (snapshot.hasError || !snapshot.hasData || snapshot.data?.statusCode != 200) {
                    return Container(
                      padding: EdgeInsets.all(20.r),
                      child: Text('Failed to load chats. Please try again.', style: GoogleFonts.outfit()),
                    );
                  }

                  final List<dynamic> fetched = snapshot.data!.data['data'] ?? [];
                  final chatThreads = List<Map<String, dynamic>>.from(fetched)
                      .where((c) => c['id'] != widget.chatId)
                      .toList();

                  if (chatThreads.isEmpty) {
                    return Container(
                      padding: EdgeInsets.all(20.r),
                      child: Text('No other active personal chats found.', style: GoogleFonts.outfit()),
                    );
                  }

                  return Container(
                    padding: EdgeInsets.all(16.r),
                    constraints: BoxConstraints(maxHeight: 400.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Forward Message',
                          style: GoogleFonts.outfit(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.darkText),
                        ),
                        SizedBox(height: 12.h),
                        Expanded(
                          child: ListView.builder(
                            itemCount: chatThreads.length,
                            itemBuilder: (context, index) {
                              final thread = chatThreads[index];
                              final avatar = thread['avatar'] as String?;
                              final name = thread['name'] as String? ?? 'PG Owner';

                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 18.r,
                                  backgroundImage: (avatar != null && avatar.isNotEmpty)
                                      ? CachedNetworkImageProvider(ApiConstants.getImageUrl(avatar)!)
                                      : null,
                                  backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.08),
                                  child: (avatar == null || avatar.isEmpty)
                                      ? Icon(Icons.person_rounded, color: AppColors.primaryBlue, size: 18.sp)
                                      : null,
                                ),
                                title: Text(
                                  name,
                                  style: GoogleFonts.outfit(fontWeight: FontWeight.w600, fontSize: 14.sp),
                                ),
                                trailing: const Icon(Icons.send_rounded, color: AppColors.primaryBlue),
                                onTap: () async {
                                  Navigator.pop(dialogContext);
                                  _forwardMessage(thread['id'], textToForward, name);
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _forwardMessage(String targetChatId, String text, String targetName) async {
    try {
      final dio = sl<Dio>();
      final response = await dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.community}/message',
        data: {'chatId': targetChatId, 'text': text},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Message forwarded to $targetName')),
          );
        }
      }
    } catch (e) {
      debugPrint('Error forwarding message: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to forward message.')),
        );
      }
    }
  }

  String _formatTime(String isoString) {
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final ampm = dt.hour >= 12 ? 'PM' : 'AM';
      final min = dt.minute < 10 ? '0${dt.minute}' : '${dt.minute}';
      return '$hour:$min $ampm';
    } catch (_) {
      return '';
    }
  }

  /// The server doesn't send delivery receipts yet; these are the fields it
  /// is expected to use. Until then every sent message shows a single tick.
  bool _isDeliveredOrRead(Map m) {
    final status = m['status']?.toString().toLowerCase();
    return status == 'delivered' ||
        status == 'read' ||
        status == 'seen' ||
        m['deliveredAt'] != null ||
        m['readAt'] != null;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedMessageId == null,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _exitSelectionMode();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        appBar: _buildAppBar(),
        body: SafeArea(
          child: Stack(
            children: [
              const Positioned.fill(
                child: CustomPaint(
                  painter: ChatWallpaperPainter(),
                ),
              ),
              Column(
                children: [
                  Expanded(
                    child: _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(color: AppColors.primaryBlue),
                          )
                        : _messages.isEmpty
                            ? _buildEmptyState()
                            : _buildMessagesList(),
                  ),
                  _buildInputSection(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    if (_selectedMessageId != null) {
      final selectedMsg = _messages.firstWhere((m) => m['_id'] == _selectedMessageId, orElse: () => {});
      final isMe = selectedMsg['sender'] == (context.read<AuthCubit>().currentOwner?.id ?? '');
      final isStarred = selectedMsg['isStarred'] as bool? ?? false;
      final textToCopyOrForward = selectedMsg['text'] as String? ?? '';

      return AppBar(
        backgroundColor: const Color(0xFF1F2C34),
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 24),
          onPressed: _exitSelectionMode,
        ),
        titleSpacing: 0,
        title: Text(
          '1',
          style: GoogleFonts.outfit(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isStarred ? Icons.star_rounded : Icons.star_border_rounded,
              color: Colors.white,
            ),
            onPressed: () {
              _toggleStarMessage(_selectedMessageId!);
              _exitSelectionMode();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_rounded, color: Colors.white),
            onPressed: () {
              _showDeleteConfirmationDialog(context, _selectedMessageId!);
            },
          ),
          IconButton(
            icon: const Icon(Icons.content_copy_rounded, color: Colors.white),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: textToCopyOrForward));
              _exitSelectionMode();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Message copied to clipboard')),
              );
            },
          ),
          IconButton(
            icon: Transform.flip(
              flipX: true,
              child: const Icon(Icons.reply_rounded, color: Colors.white),
            ),
            onPressed: () {
              _exitSelectionMode();
              _showForwardDialog(textToCopyOrForward);
            },
          ),
          if (isMe)
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: Colors.white),
              onPressed: () {
                _startEditingMessage(selectedMsg);
                _exitSelectionMode();
              },
            ),
          SizedBox(width: 8.w),
        ],
      );
    }

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          GestureDetector(
            onTap: widget.otherUserAvatar.isNotEmpty
                ? () {
                    final imageUrl = ApiConstants.getImageUrl(widget.otherUserAvatar)!;
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        opaque: false,
                        barrierColor: Colors.black87,
                        barrierDismissible: true,
                        pageBuilder: (context, animation, _) {
                          return FadeTransition(
                            opacity: animation,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Scaffold(
                                backgroundColor: Colors.transparent,
                                body: SafeArea(
                                  child: Stack(
                                    children: [
                                      Center(
                                        child: Hero(
                                          tag: 'profile_avatar_${widget.chatId}',
                                          child: InteractiveViewer(
                                            child: CachedNetworkImage(
                                              imageUrl: imageUrl,
                                              fit: BoxFit.contain,
                                              placeholder: (context, url) => const Center(
                                                child: CircularProgressIndicator(color: Colors.white),
                                              ),
                                              errorWidget: (context, url, error) => const Icon(
                                                Icons.person_rounded,
                                                color: Colors.white,
                                                size: 80,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 12,
                                        left: 12,
                                        child: GestureDetector(
                                          onTap: () => Navigator.pop(context),
                                          child: Container(
                                            padding: EdgeInsets.all(8.r),
                                            decoration: BoxDecoration(
                                              color: Colors.black45,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 24,
                                        left: 0,
                                        right: 0,
                                        child: Center(
                                          child: Text(
                                            widget.otherUserName,
                                            style: GoogleFonts.outfit(
                                              color: Colors.white,
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }
                : null,
            child: Hero(
              tag: 'profile_avatar_${widget.chatId}',
              child: CircleAvatar(
                radius: 18.r,
                backgroundImage: widget.otherUserAvatar.isNotEmpty
                    ? CachedNetworkImageProvider(ApiConstants.getImageUrl(widget.otherUserAvatar)!)
                    : null,
                backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.08),
                child: widget.otherUserAvatar.isEmpty
                    ? Icon(Icons.person_rounded, color: AppColors.primaryBlue, size: 20.sp)
                    : null,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.otherUserName,
                  style: GoogleFonts.outfit(
                    color: AppColors.darkText,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                 Text(
                  _isOnline ? 'Online' : 'Offline',
                  style: GoogleFonts.outfit(
                    color: _isOnline ? const Color(0xFF22C55E) : AppColors.greyText,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline_rounded, size: 48.sp, color: Colors.grey.shade400),
          SizedBox(height: 12.h),
          Text(
            'Start a conversation',
            style: GoogleFonts.outfit(
              fontSize: 16.sp,
              color: AppColors.darkText,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Messages are end-to-end secured.',
            style: GoogleFonts.outfit(
              fontSize: 12.sp,
              color: AppColors.greyText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    final owner = context.read<AuthCubit>().currentOwner;
    final myId = owner?.id ?? '';

    return GestureDetector(
      onTap: _exitSelectionMode,
      behavior: HitTestBehavior.opaque,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        itemCount: _messages.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final m = _messages[index];
          if (m['isDeleted'] == true) return const SizedBox.shrink();
          final text = (m['text'] as String? ?? '').trim();
          if (text.isEmpty && m['image'] == null && m['video'] == null && m['file'] == null && m['isTemp'] != true) {
            return const SizedBox.shrink();
          }
          final isMe = m['sender'] == myId;
          final time = _formatTime(m['createdAt'] ?? '');
          final reaction = m['reaction'] as String?;
          final isStarred = m['isStarred'] as bool? ?? false;
          final isSelected = _selectedMessageId == m['_id'];
          final isEdited = m['isEdited'] == true;

          return Align(
            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: isSelected
                      ? _buildFloatingReactions(m['_id'], isMe)
                      : const SizedBox(width: 0, height: 0),
                ),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    GestureDetector(
                      onLongPress: () {
                        setState(() {
                          _selectedMessageId = m['_id'];
                        });
                      },
                      onTap: () {
                        if (_selectedMessageId != null) {
                          if (isSelected) {
                            _exitSelectionMode();
                          } else {
                            setState(() {
                              _selectedMessageId = m['_id'];
                            });
                          }
                        }
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: reaction != null ? 16.h : 8.h),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isMe ? const Color(0xFF025175) : const Color(0xFFE2E8F0))
                              : (isMe ? AppColors.primaryBlue : Colors.white),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.r),
                            topRight: Radius.circular(16.r),
                            bottomLeft: isMe ? Radius.circular(16.r) : Radius.zero,
                            bottomRight: isMe ? Radius.zero : Radius.circular(16.r),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.end,
                          alignment: WrapAlignment.end,
                          spacing: 8.w,
                          runSpacing: 4.h,
                          children: [
                            Text(
                              m['text'] ?? '',
                              style: GoogleFonts.outfit(
                                color: (isSelected && !isMe)
                                    ? AppColors.darkText
                                    : (isMe ? Colors.white : AppColors.darkText),
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isEdited) ...[
                                  Text(
                                    'Edited',
                                    style: GoogleFonts.outfit(
                                      color: isMe
                                          ? Colors.white.withValues(alpha: 0.6)
                                          : AppColors.greyText.withValues(alpha: 0.6),
                                      fontSize: 9.sp,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(width: 4.w),
                                ],
                                if (isStarred) ...[
                                  Icon(
                                    Icons.star_rounded,
                                    color: Colors.amber,
                                    size: 11.sp,
                                  ),
                                  SizedBox(width: 2.w),
                                ],
                                Text(
                                  time,
                                  style: GoogleFonts.outfit(
                                    color: isMe
                                        ? Colors.white.withValues(alpha: 0.7)
                                        : AppColors.greyText,
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                if (isMe) ...[
                                  SizedBox(width: 4.w),
                                  // Clock while sending, one tick once sent,
                                  // two only when the server reports the
                                  // message as delivered or read.
                                  Icon(
                                    m['isTemp'] == true
                                        ? Icons.access_time_rounded
                                        : _isDeliveredOrRead(m)
                                        ? Icons.done_all_rounded
                                        : Icons.done_rounded,
                                    color: Colors.white.withValues(alpha: 0.8),
                                    size: 11.sp,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (reaction != null)
                      Positioned(
                        bottom: 6.h,
                        right: isMe ? 12.w : null,
                        left: !isMe ? 12.w : null,
                        child: TweenAnimationBuilder<double>(
                          key: ValueKey(reaction),
                          duration: const Duration(milliseconds: 300),
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          curve: Curves.easeOutBack,
                          builder: (context, val, child) {
                            return Transform.scale(
                              scale: val,
                              child: child,
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(color: Colors.grey.shade200, width: 1),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 2,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: Text(
                              reaction,
                              style: TextStyle(fontSize: 12.sp),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputSection() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_editingMessageId != null)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              color: const Color(0xFFF1F5F9),
              child: Row(
                children: [
                  Icon(Icons.edit_rounded, color: AppColors.primaryBlue, size: 16.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Editing Message',
                      style: GoogleFonts.outfit(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
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
                    child: Icon(Icons.close_rounded, color: AppColors.greyText, size: 16.sp),
                  ),
                ],
              ),
            ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        hintStyle: TextStyle(
                          color: AppColors.greyText.withValues(alpha: 0.6),
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        border: InputBorder.none,
                      ),
                      style: GoogleFonts.outfit(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                BouncingWrapper(
                  onTap: _sendMessage,
                  child: Container(
                    padding: EdgeInsets.all(10.r),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _editingMessageId != null ? Icons.check_rounded : Icons.send_rounded,
                      color: Colors.white,
                      size: 20.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
