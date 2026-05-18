import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/communities/domain/entities/community_entity.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';

class CommunityStoriesBar extends StatelessWidget {
  final List<CommunityDetailsEntity> communities;
  final VoidCallback onAddClick;
  final Function(CommunityDetailsEntity community) onCommunityClick;

  const CommunityStoriesBar({
    super.key,
    required this.communities,
    required this.onAddClick,
    required this.onCommunityClick,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 110.h,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: communities.length + 1,
        itemBuilder: (context, index) {
          if (index == communities.length) {
            return _buildAddButton();
          }
          final community = communities[index];
          return _buildCommunityItem(community);
        },
      ),
    );
  }

  Widget _buildAddButton() {
    return BouncingWrapper(
      onTap: onAddClick,
      child: Container(
        width: 64.w,
        margin: EdgeInsets.only(right: 16.w),
        child: Column(
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryBlue, width: 1.5),
              ),
              child: Icon(
                Icons.add_rounded,
                color: AppColors.primaryBlue,
                size: 28.sp,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Explore',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommunityItem(CommunityDetailsEntity community) {
    return BouncingWrapper(
      onTap: () => onCommunityClick(community),
      child: Container(
        width: 64.w,
        margin: EdgeInsets.only(right: 16.w),
        child: Column(
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primaryBlue, AppColors.accentOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                image: (community.image != null && community.image!.isNotEmpty)
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(
                          ApiConstants.getImageUrl(community.image) ?? '',
                        ),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: community.image == null
                  ? Icon(Icons.groups_rounded, color: Colors.white, size: 24.sp)
                  : null,
            ),
            SizedBox(height: 6.h),
            Text(
              community.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.darkText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
