import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/communities/presentation/pages/association_hierarchy_page.dart';

class CommunityDiscoveryHubPage extends StatelessWidget {
  final List<Map<String, dynamic>> allStates;
  final VoidCallback? onBack;

  const CommunityDiscoveryHubPage({
    super.key,
    required this.allStates,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildGrowthPotentialSection(),
                  _buildEmpoweringSection(),
                  _buildVisionSection(),
                  _buildFeaturesSection(),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 480.h,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primaryBlue,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () {
          if (onBack != null) {
            onBack!();
          } else {
            Navigator.pop(context);
          }
        },
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_horiz_rounded, color: Colors.white),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 100.h, 24.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Explore Communities\nby State',
                style: GoogleFonts.dmSans(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Select your state to join local owner\ncommunities',
                style: GoogleFonts.dmSans(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.4,
                ),
              ),
              SizedBox(height: 32.h),
              _buildStatesGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatesGrid(BuildContext context) {
    final Map<String, IconData> stateIconsMap = {
      'Andaman and Nicobar Islands': Icons.location_on_rounded,
      'Andhra Pradesh': Icons.account_balance_rounded,
      'Arunachal Pradesh': Icons.location_on_rounded,
      'Assam': Icons.landscape_rounded,
      'Bihar': Icons.map_rounded,
      'Chandigarh': Icons.location_on_rounded,
      'Chhattisgarh': Icons.location_on_rounded,
      'Dadra and Nagar Haveli and Daman and Diu': Icons.location_on_rounded,
    };

    final displayStates = allStates.take(8).toList();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12.h,
        crossAxisSpacing: 12.w,
        childAspectRatio: 0.72,
      ),
      itemCount: displayStates.length + 1,
      itemBuilder: (context, index) {
        if (index < displayStates.length) {
          final state = displayStates[index];
          final String name = state['name'] ?? 'Unknown';
          final IconData icon = stateIconsMap[name] ?? Icons.location_on_rounded;

          return _StateDiscoveryCard(
            name: name,
            icon: icon,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AssociationHierarchyPage(
                    parentId: state['_id'] ?? state['id'],
                    parentName: name,
                  ),
                ),
              );
            },
          );
        } else {
          return _StateDiscoveryCard(
            name: 'More',
            icon: Icons.add_rounded,
            isMore: true,
            onTap: () {},
          );
        }
      },
    );
  }

  Widget _buildGrowthPotentialSection() {
    return Padding(
      padding: EdgeInsets.all(24.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4.w,
                height: 24.h,
                decoration: BoxDecoration(
                  color: AppColors.accentOrange,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                'Our Growth Potential',
                style: GoogleFonts.dmSans(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          SizedBox(height: 32.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('28', 'states'),
              _buildStatItem('500+', 'cities'),
              _buildStatItem('10K+', 'associations'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 32.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.accentOrange,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.greyText,
          ),
        ),
      ],
    );
  }

  Widget _buildEmpoweringSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Empowering PG Owners Across\nIndia',
            style: GoogleFonts.dmSans(
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
              height: 1.2,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Join the largest network of professional accommodation providers and experience the power of unity.',
            style: GoogleFonts.dmSans(
              fontSize: 14.sp,
              color: AppColors.greyText,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisionSection() {
    return Container(
      margin: EdgeInsets.all(24.r),
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.visibility_outlined, color: AppColors.accentOrange, size: 20.sp),
              SizedBox(width: 12.w),
              Text(
                'Our Vision',
                style: GoogleFonts.dmSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            'To create a transparent, standardized, and profitable ecosystem for the accommodation and co-living industry in India.',
            style: GoogleFonts.dmSans(
              fontSize: 14.sp,
              color: AppColors.greyText,
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    final features = [
      {'title': 'Unified National Digital Platform', 'icon': Icons.hub_outlined},
      {'title': 'Local Leadership & Team Support', 'icon': Icons.face_retouching_natural_outlined},
      {'title': 'Legal & Regulatory Support', 'icon': Icons.gavel_rounded},
      {'title': 'Safety & Security Network', 'icon': Icons.security_rounded},
      {'title': 'Verified Tenant Database', 'icon': Icons.verified_user_outlined},
      {'title': 'Issue Resolution Hub', 'icon': Icons.forum_outlined},
      {'title': 'Professional Staffing Solutions', 'icon': Icons.work_outline_rounded},
      {'title': 'Strict Blacklist & Fraud Alert', 'icon': Icons.block_flipped},
      {'title': '24/7 Digital Management App', 'icon': Icons.app_registration_rounded},
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Key Features & Benefits',
            style: GoogleFonts.dmSans(
              fontSize: 20.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(height: 24.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: features.length,
            separatorBuilder: (context, index) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final feature = features[index];
              return _FeatureItem(
                title: feature['title'] as String,
                icon: feature['icon'] as IconData,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StateDiscoveryCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final VoidCallback onTap;
  final bool isMore;

  const _StateDiscoveryCard({
    required this.name,
    required this.icon,
    required this.onTap,
    this.isMore = false,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingWrapper(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: AppColors.accentOrange, size: 24.sp),
            ),
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmSans(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  color: isMore ? AppColors.darkText : AppColors.primaryBlue,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String title;
  final IconData icon;

  const _FeatureItem({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: AppColors.accentOrange, size: 18.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.dmSans(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryBlue,
              ),
            ),
          ),
          Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey[400], size: 20.sp),
        ],
      ),
    );
  }
}
