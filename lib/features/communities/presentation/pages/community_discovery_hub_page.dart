import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/communities/presentation/cubit/association_cubit.dart';
import 'package:stayindia_owner/features/communities/presentation/pages/association_hierarchy_page.dart';
import 'package:easy_localization/easy_localization.dart';

class CommunityDiscoveryHubPage extends StatefulWidget {
  final List<Map<String, dynamic>> allStates;
  final VoidCallback? onBack;

  const CommunityDiscoveryHubPage({
    super.key,
    required this.allStates,
    this.onBack,
  });

  @override
  State<CommunityDiscoveryHubPage> createState() =>
      _CommunityDiscoveryHubPageState();
}

class _CommunityDiscoveryHubPageState extends State<CommunityDiscoveryHubPage> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      if (query.length < 2) {
        setState(() {
          _searchResults = [];
          _isSearching = false;
        });
        return;
      }

      setState(() => _isSearching = true);
      final results = await context.read<AssociationCubit>().searchAssociations(
        query,
      );
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    });
  }

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
                  _buildSearchSection(context),
                  if (_searchResults.isNotEmpty || _isSearching)
                    _buildSearchResults(context)
                  else ...[
                    _buildGrowthPotentialSection(context),
                    _buildEmpoweringSection(context),
                    _buildVisionSection(context),
                    _buildFeaturesSection(context),
                  ],
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
      expandedHeight: 440.h,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primaryBlue,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () {
          if (widget.onBack != null) {
            widget.onBack!();
          } else {
            Navigator.pop(context);
          }
        },
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 100.h, 24.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'explore_communities_title'.tr(),
                style: GoogleFonts.dmSans(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.1,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'select_state_desc'.tr(),
                style: GoogleFonts.dmSans(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withValues(alpha: 0.8),
                  height: 1.4,
                ),
              ),
              SizedBox(height: 24.h),
              _buildStatesGrid(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatesGrid(BuildContext context) {
    final displayStates = widget.allStates.take(8).toList();

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

          return _StateDiscoveryCard(
            name: name,
            icon: Icons.location_on_rounded,
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
            name: 'more'.tr(),
            icon: Icons.add_rounded,
            isMore: true,
            onTap: () {},
          );
        }
      },
    );
  }

  Widget _buildSearchSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'quick_search_label'.tr(),
            style: GoogleFonts.dmSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'quick_search_desc'.tr(),
            style: GoogleFonts.dmSans(
              fontSize: 13.sp,
              color: AppColors.greyText,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            height: 56.h,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: GoogleFonts.dmSans(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'search_location_hint'.tr(),
                hintStyle: GoogleFonts.dmSans(
                  color: Colors.grey[400],
                  fontSize: 14.sp,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppColors.primaryBlue,
                  size: 22.sp,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: Colors.grey[400],
                          size: 18.sp,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchResults = []);
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 16.h),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    if (_isSearching) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 40.h),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      itemCount: _searchResults.length,
      separatorBuilder: (context, index) =>
          Divider(height: 1, color: Colors.grey.shade100),
      itemBuilder: (context, index) {
        final item = _searchResults[index];
        return ListTile(
          onTap: () => _handleLocationSelection(item),
          contentPadding: EdgeInsets.symmetric(vertical: 8.h),
          leading: Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              item['level'] == 'DISTRICT'
                  ? Icons.location_city_rounded
                  : Icons.location_on_rounded,
              color: AppColors.primaryBlue,
              size: 20.sp,
            ),
          ),
          title: Text(
            item['name'] ?? '',
            style: GoogleFonts.dmSans(
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
              fontSize: 15.sp,
            ),
          ),
          subtitle: Text(
            item['displayPath'] ?? '',
            style: GoogleFonts.dmSans(
              fontSize: 12.sp,
              color: AppColors.greyText,
              fontWeight: FontWeight.w500,
            ),
          ),
          trailing: Icon(
            Icons.arrow_forward_ios_rounded,
            size: 14.sp,
            color: Colors.grey.shade300,
          ),
        );
      },
    );
  }

  void _handleLocationSelection(Map<String, dynamic> item) {
    final String? stateName = item['state'];
    if (stateName == null) return;

    final state = widget.allStates.firstWhere(
      (s) => s['name'].toString().toLowerCase() == stateName.toLowerCase(),
      orElse: () => {},
    );

    if (state.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AssociationHierarchyPage(
            parentId: state['_id'] ?? state['id'],
            parentName: state['name'],
            initialLevel: item['level'],
            initialDistrictId: item['level'] == 'DISTRICT'
                ? item['id']
                : item['districtId'],
            initialDistrictName: item['level'] == 'DISTRICT'
                ? item['name']
                : item['district'],
            initialWardId: item['level'] == 'WARD' ? item['id'] : null,
            initialWardName: item['level'] == 'WARD' ? item['name'] : null,
          ),
        ),
      );
    }
  }

  Widget _buildGrowthPotentialSection(BuildContext context) {
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
                'our_growth_potential'.tr(),
                style: GoogleFonts.dmSans(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem(context, '28', 'states_label'.tr()),
              _buildStatItem(context, '500+', 'cities_label'.tr()),
              _buildStatItem(context, '10K+', 'associations_label'.tr()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 28.sp,
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

  Widget _buildEmpoweringSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'empowering_owners_title'.tr(),
            style: GoogleFonts.dmSans(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
              height: 1.2,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'empowering_owners_desc'.tr(),
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

  Widget _buildVisionSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(24.r),
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
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
              Icon(
                Icons.visibility_outlined,
                color: AppColors.accentOrange,
                size: 20.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'our_vision'.tr(),
                style: GoogleFonts.dmSans(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkText,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            'vision_desc'.tr(),
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

  Widget _buildFeaturesSection(BuildContext context) {
    final List<Map<String, dynamic>> features = [
      {'title': 'feature_unified_national'.tr(), 'icon': Icons.hub_outlined},
      {
        'title': 'feature_local_leadership'.tr(),
        'icon': Icons.face_retouching_natural_outlined,
      },
      {'title': 'feature_legal_support'.tr(), 'icon': Icons.gavel_rounded},
      {'title': 'feature_safety_network'.tr(), 'icon': Icons.security_rounded},
      {
        'title': 'feature_verified_tenant'.tr(),
        'icon': Icons.verified_user_outlined,
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'features_benefits_title'.tr(),
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
          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: Colors.grey[400],
            size: 20.sp,
          ),
        ],
      ),
    );
  }
}
