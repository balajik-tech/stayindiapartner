import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/custom_avatar.dart';
import 'package:stayindia_owner/features/communities/domain/entities/community_entity.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ChatMessageBubble extends StatelessWidget {
  final CommunityMessageEntity message;

  const ChatMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isSystem) {
      return _buildSystemMessage();
    }

    final bool isMe = message.isMe;

    return Padding(
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
                        Text(
                          message.text,
                          style: GoogleFonts.outfit(
                            fontSize: 15.sp,
                            color: isMe ? Colors.white : AppColors.darkText,
                            height: 1.4,
                          ),
                        ),
                      SizedBox(height: 6.h),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            _formatTime(message.createdAt),
                            style: GoogleFonts.outfit(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w500,
                              color: isMe
                                  ? Colors.white.withValues(alpha: 0.7)
                                  : AppColors.greyText,
                            ),
                          ),
                          if (isMe) ...[
                            SizedBox(width: 4.w),
                            Icon(
                              Icons.done_all_rounded,
                              size: 14.sp,
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          ],
                        ],
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
    final h = date.hour > 12
        ? date.hour - 12
        : (date.hour == 0 ? 12 : date.hour);
    final m = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }
}
