import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/custom_avatar.dart';
import 'package:stayindia_owner/features/communities/domain/entities/community_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatMessageBubble extends StatelessWidget {
  final CommunityMessageEntity message;
  final void Function(LongPressStartDetails)? onLongPressStart;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback? onTap;
  final bool isStarred;
  final void Function(String emoji)? onReact;

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.onLongPressStart,
    this.isSelected = false,
    this.isSelectionMode = false,
    this.onTap,
    this.isStarred = false,
    this.onReact,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isDeleted || (message.text.isEmpty && (message.imageUrl == null || message.imageUrl!.isEmpty))) {
      return const SizedBox.shrink();
    }

    if (message.isSystem) {
      return _buildSystemMessage();
    }

    final bool isMe = message.isMe;
    final String text = message.text;
    String actualText = text;
    String? repliedSender;
    String? repliedBody;

    final prefix = 'REPLY_TO_MSG:';
    if (text.startsWith(prefix)) {
      final body = text.substring(prefix.length);
      final parts = body.split('::REPLY_TO_MSG:');
      if (parts.length >= 2) {
        final header = parts[0];
        actualText = parts.sublist(1).join('::REPLY_TO_MSG:');
        final headerParts = header.split('::');
        if (headerParts.isNotEmpty) {
          repliedSender = headerParts[0];
          repliedBody = headerParts.sublist(1).join('::');
        }
      }
    }

    final reaction = message.reaction;

    return GestureDetector(
      onTap: isSelectionMode ? onTap : null,
      onLongPressStart: isSelectionMode
          ? null
          : (details) {
              if (!isSelectionMode && onReact != null) {
                _showReactionBar(context, isMe);
              } else if (onLongPressStart != null) {
                onLongPressStart!(details);
              }
            },
      child: Container(
        color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.12) : Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
        child: Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              CustomAvatar(
                imageUrl: message.senderAvatar,
                name: message.senderName,
                size: 32.0,
                isCircle: true,
              ),
              SizedBox(width: 8.w),
            ],
            Flexible(
              child: Column(
                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  if (!isMe)
                    Padding(
                      padding: EdgeInsets.only(left: 4.w, bottom: 4.h),
                      child: Text(
                        message.senderName,
                        style: GoogleFonts.outfit(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  // Bubble
                  Container(
                    margin: EdgeInsets.only(bottom: reaction != null ? 12.h : 4.h),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          constraints: BoxConstraints(maxWidth: 0.7.sw),
                          decoration: BoxDecoration(
                            color: isMe ? AppColors.primaryBlue : Colors.white,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(16.r),
                              topRight: Radius.circular(16.r),
                              bottomLeft: isMe ? Radius.circular(16.r) : Radius.zero,
                              bottomRight: isMe ? Radius.zero : Radius.circular(16.r),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: isMe ? null : Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (message.imageUrl != null && message.imageUrl!.isNotEmpty) ...[
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: CachedNetworkImage(
                                    imageUrl: message.imageUrl!,
                                    placeholder: (context, url) => Container(
                                      height: 150.h,
                                      width: double.infinity,
                                      color: Colors.grey[200],
                                      child: const Center(child: CircularProgressIndicator()),
                                    ),
                                    errorWidget: (context, url, error) => const Icon(Icons.error),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                if (message.text.isNotEmpty) SizedBox(height: 8.h),
                              ],
                              if (repliedSender != null && repliedBody != null)
                                _buildReplyQuoteCard(
                                  senderName: repliedSender,
                                  text: repliedBody,
                                  isMe: isMe,
                                ),
                              if (message.text.isNotEmpty)
                                _buildMessageWithInlineTime(isMe, actualText),
                            ],
                          ),
                        ),
                        // Reaction badge
                        if (reaction != null)
                          Positioned(
                            bottom: -14.h,
                            right: isMe ? 8.w : null,
                            left: isMe ? null : 8.w,
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) => ScaleTransition(
                                scale: animation,
                                child: child,
                              ),
                              child: Container(
                                key: ValueKey(reaction),
                                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(color: Colors.grey.shade200),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(reaction, style: TextStyle(fontSize: 14.sp)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isMe) SizedBox(width: 12.w),
          ],
        ),
      ),
    );
  }

  void _showReactionBar(BuildContext context, bool isMe) {
    final emojis = ['👍', '❤️', '😂', '😲', '😢', '🙏', '🔥'];
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      barrierDismissible: true,
      builder: (ctx) {
        return GestureDetector(
          onTap: () => Navigator.pop(ctx),
          behavior: HitTestBehavior.opaque,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Align(
              alignment: isMe ? Alignment.bottomRight : Alignment.bottomLeft,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 120.h),
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 250),
                  tween: Tween<double>(begin: 0.0, end: 1.0),
                  curve: Curves.easeOutBack,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Opacity(opacity: value.clamp(0.0, 1.0), child: child),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2C34),
                      borderRadius: BorderRadius.circular(30.r),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5)),
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
                              return Transform.scale(scale: val, child: child);
                            },
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(ctx);
                                onReact?.call(emoji);
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 6.w),
                                child: Text(emoji, style: TextStyle(fontSize: 22.sp)),
                              ),
                            ),
                          );
                        }),
                        // + more emojis button
                        TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 200 + (emojis.length * 35)),
                          tween: Tween<double>(begin: 0.0, end: 1.0),
                          curve: Curves.easeOutBack,
                          builder: (context, val, child) {
                            return Transform.scale(scale: val, child: child);
                          },
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(ctx);
                              _showAllEmojisPicker(context);
                            },
                            child: Container(
                              margin: EdgeInsets.only(left: 6.w),
                              padding: EdgeInsets.all(4.r),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.add, color: Colors.white70, size: 16.sp),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showAllEmojisPicker(BuildContext context) {
    final allEmojis = [
      '😀', '😃', '😄', '😁', '😆', '😅', '😂', '🤣', '😊', '😇',
      '🙂', '🙃', '😉', '😌', '😍', '🥰', '😘', '😗', '😙', '😚',
      '😋', '😛', '😝', '😜', '🤪', '🤨', '🧐', '🤓', '😎', '🥸',
      '🤩', '🥳', '😏', '😒', '😞', '😔', '😟', '😕', '🙁', '☹️',
      '😣', '😖', '😫', '😩', '🥺', '😢', '😭', '😤', '😠', '😡',
      '🤬', '🤯', '😳', '🥵', '🥶', '😱', '😨', '😰', '😥', '😓',
      '👋', '🤚', '🖐️', '✋', '🖖', '👌', '🤌', '🤏', '✌️', '🤞',
      '🤟', '🤘', '🤙', '👈', '👉', '👆', '👇', '☝️', '👍', '👎',
      '✊', '👊', '🤛', '🤜', '👏', '🙌', '👐', '🤲', '🤝', '🙏',
      '❤️', '🧡', '💛', '💚', '💙', '💜', '🖤', '🤍', '🤎', '💔',
      '❤️‍🔥', '❤️‍🩹', '❣️', '💕', '💞', '💓', '💗', '💖', '💘', '💝',
      '✨', '⭐', '🌟', '💫', '🔥', '💥', '💯', '🎉', '🎊', '🎈',
    ];

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
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
                        Navigator.pop(ctx);
                        onReact?.call(emoji);
                      },
                      child: Center(
                        child: Text(emoji, style: TextStyle(fontSize: 26.sp)),
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

  Widget _buildReplyQuoteCard({
    required String senderName,
    required String text,
    required bool isMe,
  }) {
    final barColor = isMe ? Colors.white : AppColors.primaryBlue;
    final bgColor = isMe ? Colors.white.withValues(alpha: 0.15) : Colors.grey.shade100;
    final nameColor = isMe ? Colors.white : AppColors.primaryBlue;
    final bodyColor = isMe ? Colors.white70 : Colors.grey.shade700;

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: barColor,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  senderName,
                  style: GoogleFonts.outfit(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: nameColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  text,
                  style: GoogleFonts.outfit(fontSize: 12.sp, color: bodyColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageWithInlineTime(bool isMe, String textToDisplay) {
    final timeColor = isMe ? Colors.white.withValues(alpha: 0.7) : AppColors.greyText;
    final textColor = isMe ? Colors.white : AppColors.darkText;
    final timeString = _formatTime(message.createdAt);

    final timeWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isStarred) ...[
          Icon(Icons.star_rounded, size: 14.sp, color: isMe ? Colors.amber : Colors.amber.shade700),
          SizedBox(width: 4.w),
        ],
        if (message.isEdited) ...[
          Text(
            "(edited) ",
            style: GoogleFonts.outfit(fontSize: 10.sp, fontStyle: FontStyle.italic, color: timeColor),
          ),
        ],
        Text(
          timeString,
          style: GoogleFonts.outfit(fontSize: 10.sp, fontWeight: FontWeight.w500, color: timeColor),
        ),
        if (isMe) ...[
          SizedBox(width: 4.w),
          Icon(Icons.done_all_rounded, size: 14.sp, color: timeColor),
        ],
      ],
    );

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: 2.h),
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: textToDisplay,
                  style: GoogleFonts.outfit(fontSize: 15.sp, color: textColor, height: 1.4),
                ),
                WidgetSpan(
                  child: SizedBox(
                    width: timeString.length * 6.5.w + (isMe ? 20.w : 4.w) + (message.isEdited ? 45.w : 0) + (isStarred ? 18.w : 0),
                    height: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: timeWidget,
        ),
      ],
    );
  }

  Widget _buildSystemMessage() {
    return Center(
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          message.text,
          style: GoogleFonts.outfit(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.greyText),
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final localDate = date.toLocal();
    final h = localDate.hour > 12
        ? localDate.hour - 12
        : (localDate.hour == 0 ? 12 : localDate.hour);
    final m = localDate.minute.toString().padLeft(2, '0');
    final period = localDate.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }
}
