import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/features/communities/domain/entities/community_entity.dart';

class SocialPostCard extends StatelessWidget {
  final SocialPostEntity post;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final Function(int optionIndex) onVote;
  final String currentUserId;
  final VoidCallback? onDelete;
  final VoidCallback? onShare;
  final VoidCallback? onRepost;

  const SocialPostCard({
    super.key,
    required this.post,
    required this.currentUserId,
    required this.onLike,
    required this.onComment,
    required this.onVote,
    this.onDelete,
    this.onShare,
    this.onRepost,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200, width: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildContent(),
          if (post.imageUrl != null) _buildImage(),
          if (post.poll != null) _buildPoll(),
          _buildActionBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w),
      leading: CircleAvatar(
        radius: 20.r,
        backgroundImage: post.userAvatar != null ? NetworkImage(post.userAvatar!) : null,
        child: post.userAvatar == null ? Icon(Icons.person, size: 24.sp, color: Colors.grey[400]) : null,
      ),
      title: Row(
        children: [
          Text(
            post.userName,
            style: GoogleFonts.dmSans(
              fontSize: 15.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(width: 4.w),
          if (post.type == 'UPDATE')
            Icon(Icons.verified_rounded, size: 14.sp, color: AppColors.primaryBlue),
        ],
      ),
      subtitle: Text(
        _formatDateTime(post.createdAt),
        style: GoogleFonts.dmSans(
          fontSize: 12.sp,
          color: Colors.grey[500],
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: post.userId == currentUserId && onDelete != null
          ? IconButton(
              icon: Icon(Icons.delete_outline_rounded, color: Colors.grey[400]),
              onPressed: onDelete,
            )
          : IconButton(
              icon: Icon(Icons.more_horiz_rounded, color: Colors.grey[400]),
              onPressed: () {},
            ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Text(
        post.content,
        style: GoogleFonts.dmSans(
          fontSize: 15.sp,
          color: AppColors.darkText,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 12.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: CachedNetworkImage(
          imageUrl: ApiConstants.getImageUrl(post.imageUrl!) ?? '',
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 200.h,
            color: Colors.grey[100],
            child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          ),
          errorWidget: (context, url, error) => const SizedBox(),
        ),
      ),
    );
  }

  Widget _buildPoll() {
    final options = post.poll?['options'] as List? ?? [];
    final int totalVotes = options.fold(0, (sum, opt) => sum + (opt['votes'] as int? ?? 0));
    final bool hasVoted = post.userVote != null;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        children: List.generate(options.length, (index) {
          final opt = options[index];
          final String optionText = opt['text'] ?? '';
          final int votes = opt['votes'] as int? ?? 0;
          final double percentage = totalVotes > 0 ? (votes / totalVotes) : 0.0;
          final bool isSelected = post.userVote == index;

          return GestureDetector(
            onTap: () => onVote(index),
            child: Container(
              margin: EdgeInsets.only(bottom: 8.h),
              height: 40.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: isSelected ? AppColors.primaryBlue : Colors.grey.shade200,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Stack(
                children: [
                  if (hasVoted)
                    FractionallySizedBox(
                      widthFactor: percentage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: (isSelected ? AppColors.primaryBlue : Colors.grey.shade100).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(7.r),
                        ),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            optionText,
                            style: GoogleFonts.dmSans(
                              fontSize: 13.sp,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? AppColors.primaryBlue : AppColors.darkText,
                            ),
                          ),
                        ),
                        if (hasVoted)
                          Text(
                            '${(percentage * 100).toStringAsFixed(0)}%',
                            style: GoogleFonts.dmSans(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? AppColors.primaryBlue : Colors.grey[600],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActionBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ActionBarItem(
            icon: post.isLiked ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
            label: _formatCount(post.likesCount),
            isActive: post.isLiked,
            activeColor: Colors.redAccent,
            onTap: onLike,
          ),
          _ActionBarItem(
            icon: Icons.chat_bubble_outline_rounded,
            label: _formatCount(post.commentsCount),
            onTap: onComment,
          ),
          _ActionBarItem(
            icon: Icons.repeat_rounded,
            label: 'Repost',
            onTap: onRepost ?? () {},
          ),
          _ActionBarItem(
            icon: Icons.share_outlined,
            label: 'Share',
            onTap: onShare ?? () {},
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }

  String _formatCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}K';
    return count.toString();
  }
}

class _ActionBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color? activeColor;
  final VoidCallback onTap;

  const _ActionBarItem({
    required this.icon,
    required this.label,
    this.isActive = false,
    this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? (activeColor ?? AppColors.primaryBlue) : Colors.grey[600];
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Row(
          children: [
            Icon(icon, size: 18.sp, color: color),
            SizedBox(width: 6.w),
            Text(
              label,
              style: GoogleFonts.dmSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
