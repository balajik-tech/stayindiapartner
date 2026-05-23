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

  const ChatMessageBubble({
    super.key,
    required this.message,
    this.onLongPressStart,
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

    return GestureDetector(
      onLongPressStart: onLongPressStart,
      child: Padding(
        padding: EdgeInsets.only(bottom: 16.h),
        child: Row(
          mainAxisAlignment: isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
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
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
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
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 12.h,
                  ),
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
                    border: isMe
                        ? null
                        : Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.imageUrl != null &&
                          message.imageUrl!.isNotEmpty) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: CachedNetworkImage(
                            imageUrl: message.imageUrl!,
                            placeholder: (context, url) => Container(
                              height: 150.h,
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.error),
                            fit: BoxFit.cover,
                          ),
                        ),
                        if (message.text.isNotEmpty) SizedBox(height: 8.h),
                      ],
                      if (message.text.isNotEmpty)
                        _buildMessageWithInlineTime(isMe),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isMe) SizedBox(width: 12.w),
        ],
      ),
    ));
  }

  Widget _buildMessageWithInlineTime(bool isMe) {
    final timeColor = isMe ? Colors.white.withValues(alpha: 0.7) : AppColors.greyText;
    final textColor = isMe ? Colors.white : AppColors.darkText;
    final timeString = _formatTime(message.createdAt);

    final timeWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (message.isEdited) ...[
          Text(
            "(edited) ",
            style: GoogleFonts.outfit(
              fontSize: 10.sp,
              fontStyle: FontStyle.italic,
              color: timeColor,
            ),
          ),
        ],
        Text(
          timeString,
          style: GoogleFonts.outfit(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            color: timeColor,
          ),
        ),
        if (isMe) ...[
          SizedBox(width: 4.w),
          Icon(
            Icons.done_all_rounded,
            size: 14.sp,
            color: timeColor,
          ),
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
                  text: message.text,
                  style: GoogleFonts.outfit(
                    fontSize: 15.sp,
                    color: textColor,
                    height: 1.4,
                  ),
                ),
                WidgetSpan(
                  child: SizedBox(
                    width: timeString.length * 6.5.w + (isMe ? 20.w : 4.w) + (message.isEdited ? 45.w : 0),
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
          style: GoogleFonts.outfit(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.greyText,
          ),
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
