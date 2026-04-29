import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/core/widgets/custom_avatar.dart';

class ProfileHeader extends StatelessWidget {
  final String? avatarUrl;
  final String name;
  final VoidCallback onImageTap;

  const ProfileHeader({
    super.key,
    required this.avatarUrl,
    required this.name,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          CustomAvatar(
            imageUrl: ApiConstants.getImageUrl(avatarUrl),
            name: name.isNotEmpty ? name : 'Owner',
            size: 120.0,
            isCircle: true,
            fontSize: 32.sp,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: onImageTap,
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: const BoxDecoration(
                  color: AppColors.primaryBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.camera_alt, color: Colors.white, size: 20.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
