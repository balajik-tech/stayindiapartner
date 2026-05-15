import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/communities/presentation/cubit/association_cubit.dart';
import 'package:stayindia_owner/features/communities/presentation/pages/association_hierarchy_page.dart';

class ExploreCommunitiesPage extends StatefulWidget {
  const ExploreCommunitiesPage({super.key});

  @override
  State<ExploreCommunitiesPage> createState() => _ExploreCommunitiesPageState();
}

class _ExploreCommunitiesPageState extends State<ExploreCommunitiesPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isGridView = true;
  int _maxCount = 8;

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
      backgroundColor: AppColors.primaryBlue,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: _buildTopSection(),
            ),
            SliverToBoxAdapter(
              child: _buildStatesSection(),
            ),
            SliverToBoxAdapter(
              child: SizedBox(height: 32.h),
            ),
            SliverToBoxAdapter(
              child: _buildBottomContent(),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              fillOverscroll: true,
              child: Container(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BouncingWrapper(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 22),
          ),
          SizedBox(height: 32.h),
          Text(
            'Explore\nCommunities\nby State',
            style: GoogleFonts.dmSans(
              fontSize: 34.sp,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Select your state to join local owner\ncommunities',
            style: GoogleFonts.dmSans(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
          SizedBox(height: 28.h),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 52.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() {
                      _searchQuery = val;
                      _maxCount = 8;
                    }),
                    style: GoogleFonts.dmSans(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppColors.darkText),
                    decoration: InputDecoration(
                      hintText: 'Search state...',
                      hintStyle: GoogleFonts.dmSans(color: Colors.grey.shade400, fontSize: 15.sp),
                      prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 20.sp),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.close_rounded, color: Colors.grey.shade400, size: 18.sp),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _searchQuery = '';
                                  _maxCount = 8;
                                });
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 14.h),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                height: 52.h,
                padding: EdgeInsets.all(4.r),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    BouncingWrapper(
                      onTap: () => setState(() => _isGridView = true),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: _isGridView ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.grid_view_rounded,
                          color: _isGridView ? AppColors.primaryBlue : Colors.white,
                          size: 20.sp,
                        ),
                      ),
                    ),
                    BouncingWrapper(
                      onTap: () => setState(() => _isGridView = false),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: !_isGridView ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.view_list_rounded,
                          color: !_isGridView ? AppColors.primaryBlue : Colors.white,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getStateIcon(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('andaman')) return Icons.account_balance_rounded; // Cellular Jail
    if (lower.contains('andhra')) return Icons.temple_hindu_rounded; // Tirupati
    if (lower.contains('arunachal')) return Icons.forest_rounded; // Tribal/hornbill
    if (lower.contains('assam')) return Icons.eco_rounded; // Rhino/Tea
    if (lower.contains('bihar')) return Icons.park_rounded; // Bodhi tree
    if (lower.contains('chandigarh')) return Icons.pan_tool_rounded; // Open Hand
    if (lower.contains('chhattisgarh')) return Icons.water_drop_rounded; // Waterfall
    if (lower.contains('delhi')) return Icons.account_balance_wallet_rounded; // India Gate
    if (lower.contains('goa')) return Icons.beach_access_rounded; // Beach
    if (lower.contains('gujarat')) return Icons.pets_rounded; // Lion / Statue
    if (lower.contains('haryana')) return Icons.grass_rounded; // Wheat sheaf
    if (lower.contains('himachal')) return Icons.landscape_rounded; // Snow mountain
    if (lower.contains('jammu') || lower.contains('kashmir')) return Icons.sailing_rounded; // Shikara
    if (lower.contains('jharkhand')) return Icons.waves_rounded; // Waterfall / drum
    if (lower.contains('karnataka')) return Icons.castle_rounded; // Mysore Palace
    if (lower.contains('kerala')) return Icons.houseboat_rounded; // Houseboat
    if (lower.contains('ladakh')) return Icons.filter_hdr_rounded; // Stupa / mountain
    if (lower.contains('lakshadweep')) return Icons.beach_access_rounded; // Palm / island
    if (lower.contains('madhya')) return Icons.museum_rounded; // Sanchi stupa
    if (lower.contains('maharashtra')) return Icons.door_sliding_rounded; // Gateway of India
    if (lower.contains('manipur')) return Icons.nature_people_rounded; // Sangai deer
    if (lower.contains('meghalaya')) return Icons.water_drop_rounded; // Living root bridge
    if (lower.contains('mizoram')) return Icons.forest_rounded; // Bamboo
    if (lower.contains('nagaland')) return Icons.flutter_dash_rounded; // Hornbill
    if (lower.contains('odisha')) return Icons.settings_rounded; // Konark wheel
    if (lower.contains('puducherry')) return Icons.wb_sunny_rounded; // Lighthouse
    if (lower.contains('punjab')) return Icons.wb_twilight_rounded; // Golden Temple
    if (lower.contains('rajasthan')) return Icons.fort_rounded; // Amber Fort / camel
    if (lower.contains('sikkim')) return Icons.terrain_rounded; // Kanchenjunga
    if (lower.contains('tamil')) return Icons.church_rounded; // Gopuram
    if (lower.contains('telangana')) return Icons.location_city_rounded; // Charminar
    if (lower.contains('tripura')) return Icons.water_rounded; // Water palace
    if (lower.contains('uttar pradesh')) return Icons.mosque_rounded; // Taj Mahal
    if (lower.contains('uttarakhand')) return Icons.filter_hdr_rounded; // Kedarnath
    if (lower.contains('west bengal')) return Icons.architecture_rounded; // Howrah Bridge
    return Icons.location_on_rounded;
  }

  Widget _buildStatesSection() {
    return BlocBuilder<AssociationCubit, AssociationState>(
      builder: (context, state) {
        if (state is AssociationLoading) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 40.h),
            child: const Center(child: CircularProgressIndicator(color: Colors.white)),
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
                child: Text('No states found', style: GoogleFonts.dmSans(color: Colors.white, fontSize: 16.sp)),
              ),
            );
          }

          final displayStates = filteredStates.take(_maxCount).toList();
          final hasMore = filteredStates.length > displayStates.length;

          if (!_isGridView) {
            return Column(
              children: [
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  itemCount: displayStates.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final s = displayStates[index];
                    final stateName = s['name'] as String? ?? '';
                    final stateIcon = _getStateIcon(stateName);

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
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(10.r),
                              decoration: BoxDecoration(
                                color: AppColors.accentOrange.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Icon(stateIcon, color: AppColors.accentOrange, size: 20.sp),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Text(
                                stateName,
                                style: GoogleFonts.dmSans(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.darkText),
                              ),
                            ),
                            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                if (hasMore) ...[
                  SizedBox(height: 16.h),
                  BouncingWrapper(
                    onTap: () => setState(() => _maxCount += 8),
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 24.w),
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: AppColors.primaryBlue, size: 20.sp),
                          SizedBox(width: 8.w),
                          Text(
                            'Show More States',
                            style: GoogleFonts.dmSans(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            );
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 12.w,
              childAspectRatio: 0.72,
            ),
            itemCount: displayStates.length + (hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index < displayStates.length) {
                final s = displayStates[index];
                final stateName = s['name'] as String? ?? '';
                final stateIcon = _getStateIcon(stateName);

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
                            shape: BoxShape.circle,
                          ),
                          child: Icon(stateIcon, color: AppColors.accentOrange, size: 22.sp),
                        ),
                        SizedBox(height: 8.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 6.w),
                          child: Text(
                            stateName,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.dmSans(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                return BouncingWrapper(
                  onTap: () {
                    setState(() => _maxCount += 8);
                  },
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
                            color: AppColors.primaryBlue.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.add, color: AppColors.primaryBlue, size: 22.sp),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'More',
                          style: GoogleFonts.dmSans(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildBottomContent() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
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
                SizedBox(height: 32.h),
                Text(
                  'Empowering PG Owners\nAcross India',
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
                    fontSize: 15.sp,
                    color: AppColors.greyText,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 24.w),
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
                    Icon(Icons.visibility_outlined, color: AppColors.accentOrange, size: 22.sp),
                    SizedBox(width: 12.w),
                    Text(
                      'Our Vision',
                      style: GoogleFonts.dmSans(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkText,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  'To create a transparent, standardized, and profitable ecosystem for the student housing and co-living industry in India.',
                  style: GoogleFonts.dmSans(
                    fontSize: 14.sp,
                    color: AppColors.greyText,
                    height: 1.6,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              'Key Features & Benefits',
              style: GoogleFonts.dmSans(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.darkText,
              ),
            ),
          ),
          SizedBox(height: 20.h),
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

  Widget _buildAccordionFeatures() {
    final features = [
      {
        'title': 'Unified National Digital Platform',
        'icon': Icons.hub_outlined,
        'desc': 'Connect with property owners across India on a single seamless network.',
      },
      {
        'title': 'Local Leadership & Team Support',
        'icon': Icons.face_retouching_natural_outlined,
        'desc': 'Dedicated city and state leadership teams to guide and assist you locally.',
      },
      {
        'title': 'Legal & Regulatory Support',
        'icon': Icons.gavel_rounded,
        'desc': 'Access expert advice and documentation assistance for compliance and regulations.',
      },
      {
        'title': 'Safety & Security Network',
        'icon': Icons.security_rounded,
        'desc': 'Shared alert mechanisms and security protocols for safer living environments.',
      },
      {
        'title': 'Verified Tenant Database',
        'icon': Icons.verified_user_outlined,
        'desc': 'Background-checked tenant profiles to minimize risks and ensure reliable occupancy.',
      },
      {
        'title': 'Issue Resolution Hub',
        'icon': Icons.forum_outlined,
        'desc': 'Dedicated mediation channels for resolving disputes quickly and fairly.',
      },
      {
        'title': 'Professional Staffing Solutions',
        'icon': Icons.work_outline_rounded,
        'desc': 'Verified staff hiring network for managers, housekeeping, and security personnel.',
      },
      {
        'title': 'Strict Blacklist & Fraud Alert System',
        'icon': Icons.block_flipped,
        'desc': 'National alert system to report and prevent fraud and problematic tenants instantly.',
      },
      {
        'title': '24/7 Digital Management App',
        'icon': Icons.app_registration_rounded,
        'desc': 'Manage notices, rent dues, stock, and community chats anytime, anywhere.',
      },
      {
        'title': 'Standardized Quality of Living',
        'icon': Icons.star_border_rounded,
        'desc': 'Implementing best practices and benchmarks to elevate property standards nationwide.',
      },
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      itemCount: features.length,
      separatorBuilder: (context, index) => SizedBox(height: 12.h),
      itemBuilder: (context, index) {
        final f = features[index];
        return _ExpandableFeatureItem(
          title: f['title'] as String,
          icon: f['icon'] as IconData,
          description: f['desc'] as String,
        );
      },
    );
  }
}

class _ExpandableFeatureItem extends StatefulWidget {
  final String title;
  final IconData icon;
  final String description;

  const _ExpandableFeatureItem({
    required this.title,
    required this.icon,
    required this.description,
  });

  @override
  State<_ExpandableFeatureItem> createState() => _ExpandableFeatureItemState();
}

class _ExpandableFeatureItemState extends State<_ExpandableFeatureItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.01),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          onExpansionChanged: (val) => setState(() => _isExpanded = val),
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          leading: Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: AppColors.accentOrange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(widget.icon, color: AppColors.accentOrange, size: 20.sp),
          ),
          title: Text(
            widget.title,
            style: GoogleFonts.dmSans(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryBlue,
            ),
          ),
          trailing: Icon(
            _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
            color: Colors.grey[400],
            size: 24.sp,
          ),
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
              child: Text(
                widget.description,
                style: GoogleFonts.dmSans(
                  fontSize: 14.sp,
                  color: AppColors.greyText,
                  height: 1.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
