import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/communities/presentation/cubit/association_cubit.dart';
import 'package:stayindia_owner/features/communities/presentation/pages/association_hierarchy_page.dart';
import 'package:easy_localization/easy_localization.dart';

class ExploreCommunitiesPage extends StatefulWidget {
  const ExploreCommunitiesPage({super.key});

  @override
  State<ExploreCommunitiesPage> createState() => _ExploreCommunitiesPageState();
}

class _ExploreCommunitiesPageState extends State<ExploreCommunitiesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _maxCount = 15;

  @override
  void initState() {
    super.initState();
    context.read<AssociationCubit>().loadStates();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: _buildTopSection()),
            SliverToBoxAdapter(child: _buildStatesSection()),
            SliverToBoxAdapter(child: SizedBox(height: 48.h)),
            SliverToBoxAdapter(child: _buildBottomContent()),
            SliverFillRemaining(
              hasScrollBody: false,
              fillOverscroll: true,
              child: Container(color: const Color(0xFFF8FAFC)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BouncingWrapper(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFF1F5F9)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.arrow_back_rounded,
                color: AppColors.darkText,
                size: 20.sp,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'Explore Communities',
            style: GoogleFonts.inter(
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Join local PG owner networks',
            style: GoogleFonts.inter(
              fontSize: 15.sp,
              fontWeight: FontWeight.w400,
              color: AppColors.greyText,
              height: 1.4,
            ),
          ),
          SizedBox(height: 24.h),
          Container(
            height: 50.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() {
                _searchQuery = val;
                _maxCount = 15;
              }),
              style: GoogleFonts.inter(
                fontSize: 15.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.darkText,
              ),
              decoration: InputDecoration(
                hintText: 'Search states...',
                hintStyle: GoogleFonts.inter(
                  color: Colors.grey.shade400,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w400,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: Colors.grey.shade400,
                  size: 20.sp,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: Colors.grey.shade400,
                          size: 18.sp,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                            _maxCount = 15;
                          });
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14.h),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getStateIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('andaman')) return Icons.account_balance_rounded;
    if (lower.contains('andhra')) return Icons.temple_hindu_rounded;
    if (lower.contains('arunachal')) return Icons.forest_rounded;
    if (lower.contains('assam')) return Icons.eco_rounded;
    if (lower.contains('bihar')) return Icons.park_rounded;
    if (lower.contains('chandigarh')) return Icons.pan_tool_rounded;
    if (lower.contains('chhattisgarh')) return Icons.water_drop_rounded;
    if (lower.contains('delhi')) return Icons.account_balance_wallet_rounded;
    if (lower.contains('goa')) return Icons.beach_access_rounded;
    if (lower.contains('gujarat')) return Icons.pets_rounded;
    if (lower.contains('haryana')) return Icons.grass_rounded;
    if (lower.contains('himachal')) return Icons.landscape_rounded;
    if (lower.contains('jammu') || lower.contains('kashmir')) {
      return Icons.sailing_rounded;
    }
    if (lower.contains('jharkhand')) return Icons.waves_rounded;
    if (lower.contains('karnataka')) return Icons.castle_rounded;
    if (lower.contains('kerala')) return Icons.houseboat_rounded;
    if (lower.contains('ladakh')) return Icons.filter_hdr_rounded;
    if (lower.contains('lakshadweep')) return Icons.beach_access_rounded;
    if (lower.contains('madhya')) return Icons.museum_rounded;
    if (lower.contains('maharashtra')) return Icons.door_sliding_rounded;
    if (lower.contains('manipur')) return Icons.nature_people_rounded;
    if (lower.contains('meghalaya')) return Icons.water_drop_rounded;
    if (lower.contains('mizoram')) return Icons.forest_rounded;
    if (lower.contains('nagaland')) return Icons.flutter_dash_rounded;
    if (lower.contains('odisha')) return Icons.settings_rounded;
    if (lower.contains('puducherry')) return Icons.wb_sunny_rounded;
    if (lower.contains('punjab')) return Icons.wb_twilight_rounded;
    if (lower.contains('rajasthan')) return Icons.fort_rounded;
    if (lower.contains('sikkim')) return Icons.terrain_rounded;
    if (lower.contains('tamil')) return Icons.church_rounded;
    if (lower.contains('telangana')) return Icons.location_city_rounded;
    if (lower.contains('tripura')) return Icons.water_rounded;
    if (lower.contains('uttar pradesh')) return Icons.mosque_rounded;
    if (lower.contains('uttarakhand')) return Icons.filter_hdr_rounded;
    if (lower.contains('west bengal')) return Icons.architecture_rounded;
    return Icons.location_on_rounded;
  }

  Color _getStateColor(String name, int index) {
    final colors = [
      const Color(0xFF0284C7),
      const Color(0xFF0D9488),
      const Color(0xFF7C3AED),
      const Color(0xFFEA580C),
      const Color(0xFFE11D48),
      const Color(0xFF16A34A),
      const Color(0xFF4F46E5),
      const Color(0xFFDB2777),
      const Color(0xFFB45309),
      const Color(0xFF06B6D4),
      const Color(0xFF059669),
      const Color(0xFFDC2626),
      const Color(0xFF8B5CF6),
      const Color(0xFFF43F5E),
      const Color(0xFF6366F1),
      const Color(0xFF84CC16),
    ];
    final hash = name.codeUnits.fold<int>(0, (prev, element) => prev + element);
    return colors[(hash + index) % colors.length];
  }

  Color _getFeatureColor(int index) {
    final colors = [
      const Color(0xFF4F46E5),
      const Color(0xFF0D9488),
      const Color(0xFFB45309),
      const Color(0xFFE11D48),
      const Color(0xFF16A34A),
      const Color(0xFF7C3AED),
      const Color(0xFF0284C7),
      const Color(0xFFEA580C),
      const Color(0xFFDB2777),
      const Color(0xFF059669),
    ];
    return colors[index % colors.length];
  }

  Widget _buildStatesSection() {
    return BlocBuilder<AssociationCubit, AssociationState>(
      builder: (context, state) {
        if (state is AssociationLoading) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            ),
          );
        }
        if (state is AssociationLoaded) {
          final allStates = state.states;
          final filteredStates = allStates.where((s) {
            final name = (s['name'] as String).toLowerCase();
            return name.contains(_searchQuery.toLowerCase());
          }).toList();

          if (filteredStates.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.h),
                child: Text(
                  'no_states_found'.tr(),
                  style: GoogleFonts.inter(
                    color: AppColors.greyText,
                    fontSize: 15.sp,
                  ),
                ),
              ),
            );
          }

          final displayStates = filteredStates.take(_maxCount).toList();
          final hasMore = filteredStates.length > displayStates.length;

          return Column(
            children: [
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                itemCount: displayStates.length,
                separatorBuilder: (context, index) => SizedBox(height: 10.h),
                itemBuilder: (context, index) {
                  final s = displayStates[index];
                  final stateName = s['name'] as String? ?? '';
                  final stateIcon = _getStateIcon(stateName);
                  final Color baseColor = _getStateColor(stateName, index);

                  return BouncingWrapper(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AssociationHierarchyPage(
                            parentId: s['_id'] ?? s['id'],
                            parentName: stateName,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: baseColor.withValues(alpha: 0.12),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: baseColor.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(10.r),
                            decoration: BoxDecoration(
                              color: baseColor.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: baseColor.withValues(alpha: 0.15),
                              ),
                            ),
                            child: Icon(
                              stateIcon,
                              color: baseColor,
                              size: 18.sp,
                            ),
                          ),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  stateName,
                                  style: GoogleFonts.inter(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkText,
                                  ),
                                ),
                                SizedBox(height: 3.h),
                                Text(
                                  'Active community',
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.greyText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: baseColor.withValues(alpha: 0.4),
                            size: 14.sp,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              if (hasMore) ...[
                SizedBox(height: 16.h),
                BouncingWrapper(
                  onTap: () => setState(() => _maxCount += 15),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20.w),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Load more states',
                      style: GoogleFonts.inter(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkText,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBottomContent() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Network Growth',
                  style: GoogleFonts.inter(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem('28', 'States'),
                    _buildStatItem('500+', 'Cities'),
                    _buildStatItem('10K+', 'Communities'),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: const Color(0xFFF1F5F9)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.r),
                      decoration: BoxDecoration(
                        color: AppColors.accentOrange.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Icon(
                        Icons.visibility_outlined,
                        color: AppColors.accentOrange,
                        size: 16.sp,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'Our Vision',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  'vision_statement'.tr(),
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    color: AppColors.greyText,
                    height: 1.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),
          Text(
            'Features & Benefits',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(height: 16.h),
          _buildAccordionFeatures(),
          SizedBox(height: 80.h),
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
          style: GoogleFonts.inter(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.accentOrange,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.greyText,
          ),
        ),
      ],
    );
  }

  Widget _buildAccordionFeatures() {
    final features = [
      {
        'title': 'feature_unified_national'.tr(),
        'icon': Icons.hub_outlined,
        'desc': 'feature_unified_national_desc'.tr(),
      },
      {
        'title': 'feature_leadership_support'.tr(),
        'icon': Icons.face_retouching_natural_outlined,
        'desc': 'feature_leadership_support_desc'.tr(),
      },
      {
        'title': 'feature_legal_regulatory'.tr(),
        'icon': Icons.gavel_rounded,
        'desc': 'feature_legal_regulatory_desc'.tr(),
      },
      {
        'title': 'feature_safety_security'.tr(),
        'icon': Icons.security_rounded,
        'desc': 'feature_safety_security_desc'.tr(),
      },
      {
        'title': 'feature_tenant_verification'.tr(),
        'icon': Icons.verified_user_outlined,
        'desc': 'feature_tenant_verification_desc'.tr(),
      },
      {
        'title': 'feature_issue_resolution'.tr(),
        'icon': Icons.forum_outlined,
        'desc': 'feature_issue_resolution_desc'.tr(),
      },
      {
        'title': 'feature_staffing_solutions'.tr(),
        'icon': Icons.work_outline_rounded,
        'desc': 'feature_staffing_solutions_desc'.tr(),
      },
      {
        'title': 'feature_blacklist_system'.tr(),
        'icon': Icons.block_flipped,
        'desc': 'feature_blacklist_system_desc'.tr(),
      },
      {
        'title': 'feature_digital_mgmt'.tr(),
        'icon': Icons.app_registration_rounded,
        'desc': 'feature_digital_mgmt_desc'.tr(),
      },
      {
        'title': 'feature_quality_living'.tr(),
        'icon': Icons.star_border_rounded,
        'desc': 'feature_quality_living_desc'.tr(),
      },
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemCount: features.length,
      separatorBuilder: (context, index) => SizedBox(height: 10.h),
      itemBuilder: (context, index) {
        final f = features[index];
        return _ExpandableFeatureItem(
          title: f['title'] as String,
          icon: f['icon'] as IconData,
          description: f['desc'] as String,
          accentColor: _getFeatureColor(index),
        );
      },
    );
  }
}

class _ExpandableFeatureItem extends StatefulWidget {
  final String title;
  final IconData icon;
  final String description;
  final Color accentColor;

  const _ExpandableFeatureItem({
    required this.title,
    required this.icon,
    required this.description,
    required this.accentColor,
  });

  @override
  State<_ExpandableFeatureItem> createState() => _ExpandableFeatureItemState();
}

class _ExpandableFeatureItemState extends State<_ExpandableFeatureItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: _isExpanded
              ? widget.accentColor.withValues(alpha: 0.3)
              : const Color(0xFFF1F5F9),
          width: _isExpanded ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _isExpanded
                ? widget.accentColor.withValues(alpha: 0.04)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: (val) => setState(() => _isExpanded = val),
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0),
          minTileHeight: 56.h,
          leading: Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: widget.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(widget.icon, color: widget.accentColor, size: 16.sp),
          ),
          title: Text(
            widget.title,
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.darkText,
            ),
          ),
          trailing: Icon(
            _isExpanded
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            color: _isExpanded ? widget.accentColor : Colors.grey[400],
            size: 20.sp,
          ),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: Text(
                widget.description,
                style: GoogleFonts.inter(
                  fontSize: 14.sp,
                  color: AppColors.greyText,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
