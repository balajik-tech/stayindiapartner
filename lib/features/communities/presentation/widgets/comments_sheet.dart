import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/communities/domain/entities/community_entity.dart';
import 'package:stayindia_owner/features/communities/domain/usecases/community_usecases.dart';
import 'package:stayindia_owner/injection_container.dart';
import 'package:stayindia_owner/core/utils/logger.dart';
import 'package:easy_localization/easy_localization.dart';

class CommentsSheet extends StatefulWidget {
  final SocialPostEntity post;
  const CommentsSheet({super.key, required this.post});

  @override
  State<CommentsSheet> createState() => CommentsSheetState();
}

class CommentsSheetState extends State<CommentsSheet> {
  final TextEditingController _commentController = TextEditingController();
  List<Map<String, dynamic>> _comments = [];
  bool _isLoading = true;
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    try {
      final results = await sl<GetPostCommentsUseCase>().call(widget.post.id);
      if (mounted) {
        setState(() {
          _comments = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      AppLogger.error('Error loading comments: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) {
      return;
    }

    setState(() => _isPosting = true);
    try {
      await sl<AddPostCommentUseCase>().call(widget.post.id, text);
      _commentController.clear();
      
      await _loadComments();
      if (mounted) {
        setState(() => _isPosting = false);
      }
    } catch (e) {
      AppLogger.error('Error adding comment: $e');
      if (mounted) {
        setState(() => _isPosting = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('failed_add_comment'.tr())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: Column(
        children: [
          SizedBox(height: 12.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.r),
            child: Text(
              'comments_title'.tr(),
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800),
            ),
          ),
          Divider(height: 1, color: Colors.grey[100]),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryBlue,
                    ),
                  )
                : _comments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 48.sp,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'no_comments_yet'.tr(),
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(20.r),
                    itemCount: _comments.length,
                    itemBuilder: (context, index) =>
                        _buildCommentItem(_comments[index]),
                  ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 30.h),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[100]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: TextField(
                      controller: _commentController,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: 'write_comment_hint'.tr(),
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                BouncingWrapper(
                  onTap: _isPosting ? null : _addComment,
                  child: Container(
                    padding: EdgeInsets.all(12.r),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                    child: _isPosting
                        ? SizedBox(
                            width: 18.r,
                            height: 18.r,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Icon(
                            Icons.send_rounded,
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

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    final userData = comment['userId'] is Map ? comment['userId'] : {};
    final userName = (userData['name']?.toString().isNotEmpty == true) ? userData['name'] :
                     (userData['firstName']?.toString().isNotEmpty == true) ? 
                        '${userData['firstName']}${userData['lastName'] != null ? ' ${userData['lastName']}' : ''}' : 'User';
    final userAvatar = userData['avatar']?.toString();

    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.05),
            child: ClipOval(
              child: (userAvatar != null && userAvatar.isNotEmpty)
                  ? CachedNetworkImage(
                      imageUrl: ApiConstants.getImageUrl(userAvatar) ?? '',
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Text(
                        userName[0].toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryBlue,
                          fontSize: 14.sp,
                        ),
                      ),
                    )
                  : Text(
                      userName[0].toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primaryBlue,
                        fontSize: 14.sp,
                      ),
                    ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.all(12.r),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkText,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        comment['text']?.toString() ?? '',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.darkText,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  _formatTime(comment['createdAt']),
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.greyText,
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

  String _formatTime(dynamic date) {
    if (date == null) return '';
    try {
      final dt = DateTime.parse(date.toString());
      final diff = DateTime.now().difference(dt);
      if (diff.inDays > 0) return 'time_day_short'.tr(namedArgs: {'count': diff.inDays.toString()});
      if (diff.inHours > 0) return 'time_hour_short'.tr(namedArgs: {'count': diff.inHours.toString()});
      if (diff.inMinutes > 0) return 'time_minute_short'.tr(namedArgs: {'count': diff.inMinutes.toString()});
      return 'time_now'.tr();
    } catch (e) {
      return '';
    }
  }
}

class DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;

  DashedCirclePainter({
    this.color = const Color(0xFF2C5990),
    this.strokeWidth = 1.5,
    this.dashWidth = 5,
    this.dashSpace = 3,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    const double startAngle = 0;
    const double totalAngle = 2 * 3.1415926535897932;

    final double dashAngle = dashWidth / radius;
    final double spaceAngle = dashSpace / radius;

    double currentAngle = startAngle;
    while (currentAngle < totalAngle) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        currentAngle,
        dashAngle,
        false,
        paint,
      );
      currentAngle += dashAngle + spaceAngle;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
