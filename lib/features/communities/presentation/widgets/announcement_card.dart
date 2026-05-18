import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/communities/domain/entities/community_entity.dart';

class AnnouncementCard extends StatelessWidget {
  final AnnouncementEntity announcement;

  const AnnouncementCard({super.key, required this.announcement});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.roomCardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 12.h),
          Text(
            announcement.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 18.sp,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            announcement.content,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14.sp,
              height: 1.5,
            ),
          ),
          SizedBox(height: 16.h),
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            'OFFICIAL',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        Text(
          _formatDate(announcement.createdAt),
          style: TextStyle(color: AppColors.greyText, fontSize: 11.sp),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        CircleAvatar(
          radius: 12.r,
          backgroundColor: AppColors.primaryBlue,
          child: Icon(Icons.person, size: 14.sp, color: Colors.white),
        ),
        SizedBox(width: 8.w),
        Text(
          'Broadcasted by Owner',
          style: TextStyle(
            color: AppColors.greyText,
            fontSize: 12.sp,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    if (date.year == now.year &&
        date.month == now.month &&
        date.day == now.day) {
      return 'Today, ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}
