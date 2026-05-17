import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/communities/presentation/cubit/association_cubit.dart';
import 'package:stayindia_owner/features/communities/presentation/cubit/owner_community_cubit.dart';
import 'package:stayindia_owner/features/communities/domain/entities/community_entity.dart';
import 'package:stayindia_owner/features/communities/presentation/pages/community_detail_page.dart';
import 'package:stayindia_owner/features/communities/presentation/pages/create_community_page.dart';
import 'package:stayindia_owner/core/constants/api_constants.dart';
import 'package:stayindia_owner/core/utils/string_utils.dart';

class AssociationHierarchyPage extends StatefulWidget {
  final String parentId; 
  final String parentName; 
  final String? initialLevel;
  final String? initialDistrictId;
  final String? initialDistrictName;
  final String? initialWardId;
  final String? initialWardName;

  const AssociationHierarchyPage({
    super.key,
    required this.parentId,
    required this.parentName,
    this.initialLevel,
    this.initialDistrictId,
    this.initialDistrictName,
    this.initialWardId,
    this.initialWardName,
  });

  @override
  State<AssociationHierarchyPage> createState() => _AssociationHierarchyPageState();
}

class _AssociationHierarchyPageState extends State<AssociationHierarchyPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  
  String? _selectedDistrictId;
  String? _selectedDistrictName;
  String? _selectedWardId;
  String? _selectedWardName;

  @override
  void initState() {
    super.initState();
    int initialIndex = 0;
    if (widget.initialLevel == 'DISTRICT') initialIndex = 1;
    if (widget.initialLevel == 'WARD') initialIndex = 2;

    _tabController = TabController(length: 3, vsync: this, initialIndex: initialIndex);
    _tabController.addListener(_handleTabChange);
    
    _selectedDistrictId = widget.initialDistrictId;
    _selectedDistrictName = widget.initialDistrictName;
    _selectedWardId = widget.initialWardId;
    _selectedWardName = widget.initialWardName;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshLevelData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      _searchQuery = '';
      _searchController.clear();
    });
    _refreshLevelData();
  }

  void _refreshLevelData() {
    final level = _getCurrentLevel();
    if (level == 'STATE') {
      _loadStateCommunities();
    } else if (level == 'DISTRICT') {
      if (_selectedDistrictId == null) {
        context.read<AssociationCubit>().loadDistricts(widget.parentId);
      } else {
        _loadDistrictCommunities();
      }
    } else if (level == 'WARD') {
      if (_selectedDistrictId == null) {
        
      } else if (_selectedWardId == null) {
        context.read<AssociationCubit>().loadWards(_selectedDistrictId!);
      } else {
        _loadWardCommunities();
      }
    }
  }

  String _getCurrentLevel() {
    return _tabController.index == 0 ? 'STATE' : (_tabController.index == 1 ? 'DISTRICT' : 'WARD');
  }

  void _loadStateCommunities() {
    context.read<OwnerCommunityCubit>().discoverCommunities(
      level: 'STATE',
      stateId: widget.parentId,
    );
  }

  void _loadDistrictCommunities() {
    context.read<OwnerCommunityCubit>().discoverCommunities(
      level: 'DISTRICT',
      stateId: widget.parentId,
      districtId: _selectedDistrictId,
    );
  }

  void _loadWardCommunities() {
    context.read<OwnerCommunityCubit>().discoverCommunities(
      level: 'WARD',
      stateId: widget.parentId,
      districtId: _selectedDistrictId,
      wardId: _selectedWardId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(),
          _buildTabSwitcher(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildLevelView('STATE'),
                _buildLevelView('DISTRICT'),
                _buildLevelView('WARD'),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, _) {
              final level = _getCurrentLevel();
              final isSelecting = (level == 'DISTRICT' && _selectedDistrictId == null) || 
                                 (level == 'WARD' && _selectedWardId == null);
              
              if (isSelecting) return const SizedBox();
              return _buildBottomCreateButton();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 64.h, 20.w, 32.h),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          BouncingWrapper(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.parentName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  StringUtils.translate('national_level_communities', namedArgs: {'name': widget.parentName}, context: context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      margin: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 12.h),
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTabItem(StringUtils.translate('level_state', context: context), 0),
          _buildTabItem(StringUtils.translate('level_district', context: context), 1),
          _buildTabItem(StringUtils.translate('level_ward', context: context), 2),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    final isSelected = _tabController.index == index;
    return Expanded(
      child: BouncingWrapper(
        onTap: () => _tabController.animateTo(index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(12.r),
          ),
          alignment: Alignment.center,
          child: Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 11.sp,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLevelView(String level) {
    if (level == 'WARD' && _selectedDistrictId == null) {
      return _buildSelectionRequiredView(StringUtils.translate('district_label', context: context));
    }

    final isSelecting = (level == 'DISTRICT' && _selectedDistrictId == null) || 
                       (level == 'WARD' && _selectedWardId == null);

    final title = level == 'STATE' 
        ? StringUtils.translate('state_level_communities', namedArgs: {'name': widget.parentName}, context: context)
        : (level == 'DISTRICT' 
            ? (_selectedDistrictId == null ? StringUtils.translate('explore_districts_in', namedArgs: {'name': widget.parentName}, context: context) : StringUtils.translate('communities_in', namedArgs: {'name': _selectedDistrictName!}, context: context))
            : (_selectedWardId == null ? StringUtils.translate('explore_wards_in', namedArgs: {'name': _selectedDistrictName!}, context: context) : StringUtils.translate('communities_in', namedArgs: {'name': _selectedWardName!}, context: context)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 8.h),
          child: Text(
            title,
            style: GoogleFonts.dmSans(
              fontSize: 18.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              height: 1.3,
            ),
          ),
        ),
        if (isSelecting) _buildSearchBar(level),
        if (level == 'DISTRICT' && _selectedDistrictId != null)
          _buildSelectionChip(StringUtils.translate('district_label', context: context), _selectedDistrictName!, () {
            setState(() {
              _selectedDistrictId = null;
              _selectedDistrictName = null;
              _selectedWardId = null;
              _selectedWardName = null;
              context.read<AssociationCubit>().loadDistricts(widget.parentId);
            });
          }),
        if (level == 'WARD' && _selectedWardId != null)
          _buildSelectionChip(StringUtils.translate('ward_label', context: context), _selectedWardName!, () {
            setState(() {
              _selectedWardId = null;
              _selectedWardName = null;
              context.read<AssociationCubit>().loadWards(_selectedDistrictId!);
            });
          }),
        Expanded(
          child: isSelecting 
            ? _buildSelectionGrid(level)
            : _buildCommunityListOrEmpty(level),
        ),
      ],
    );
  }

  Widget _buildSearchBar(String level) {
    return Container(
      margin: EdgeInsets.fromLTRB(24.w, 4.h, 24.w, 12.h),
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val),
        style: GoogleFonts.dmSans(fontSize: 14.sp, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: StringUtils.translate('search_level_hint', namedArgs: {'level': level == 'STATE' ? StringUtils.translate('level_state', context: context) : (level == 'DISTRICT' ? StringUtils.translate('level_district', context: context) : StringUtils.translate('level_ward', context: context))}, context: context),
          hintStyle: GoogleFonts.dmSans(color: Colors.grey[400], fontSize: 13.sp),
          prefixIcon: Icon(Icons.search_rounded, color: Colors.grey[400], size: 18.sp),
          suffixIcon: _searchQuery.isNotEmpty 
            ? IconButton(
                icon: Icon(Icons.close_rounded, color: Colors.grey[400], size: 16.sp),
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
              )
            : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12.h),
        ),
      ),
    );
  }

  Widget _buildSelectionChip(String label, String name, VoidCallback onRemove) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 12.h),
      alignment: Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: ',
              style: GoogleFonts.dmSans(fontSize: 12.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
            ),
            Text(
              name,
              style: GoogleFonts.dmSans(fontSize: 12.sp, fontWeight: FontWeight.w800, color: AppColors.primaryBlue),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: onRemove,
              child: Icon(Icons.close_rounded, size: 14.sp, color: AppColors.primaryBlue),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionRequiredView(String requirement) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(40.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.r),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.info_outline_rounded, size: 40.sp, color: AppColors.textSecondary.withValues(alpha: 0.3)),
            ),
            SizedBox(height: 24.h),
            Text(
              StringUtils.translate('selection_required', context: context),
              style: GoogleFonts.dmSans(fontSize: 18.sp, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            SizedBox(height: 8.h),
            Text(
              StringUtils.translate('selection_required_desc', namedArgs: {'requirement': requirement}, context: context),
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(fontSize: 14.sp, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: 32.h),
            BouncingWrapper(
              onTap: () => _tabController.animateTo(1),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  StringUtils.translate('go_to_district_tab', context: context),
                  style: GoogleFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionGrid(String level) {
    return BlocBuilder<AssociationCubit, AssociationState>(
      builder: (context, state) {
        if (state is AssociationLoading || (state is AssociationLoaded && state.isSubLoading)) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is AssociationLoaded) {
          final allItems = level == 'DISTRICT' ? state.districts : state.wards;
          if (allItems == null || allItems.isEmpty) {
            return Center(child: Text(StringUtils.translate('no_level_items_found', namedArgs: {'level': level}, context: context), style: GoogleFonts.dmSans(color: AppColors.textSecondary)));
          }

          final filteredItems = allItems.where((item) {
            final name = (item['name'] as String).toLowerCase();
            return name.contains(_searchQuery.toLowerCase());
          }).toList();

          if (filteredItems.isEmpty) {
            return Center(child: Text(StringUtils.translate('no_states_found', context: context), style: GoogleFonts.dmSans(color: AppColors.textSecondary)));
          }

          return GridView.builder(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 12.h,
              crossAxisSpacing: 10.w,
              childAspectRatio: 0.8,
            ),
            itemCount: filteredItems.length,
            itemBuilder: (context, index) {
              final item = filteredItems[index];
              return _SelectionCard(
                name: item['name'],
                icon: level == 'DISTRICT' ? Icons.location_city_rounded : Icons.holiday_village_rounded,
                onTap: () {
                  setState(() {
                    if (level == 'DISTRICT') {
                      _selectedDistrictId = item['_id'] ?? item['id'];
                      _selectedDistrictName = item['name'];
                      _selectedWardId = null;
                      _selectedWardName = null;
                      _loadDistrictCommunities();
                    } else {
                      _selectedWardId = item['_id'] ?? item['id'];
                      _selectedWardName = item['name'];
                      _loadWardCommunities();
                    }
                    _searchQuery = '';
                    _searchController.clear();
                  });
                },
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }

  Widget _buildCommunityListOrEmpty(String level) {
    return BlocBuilder<OwnerCommunityCubit, OwnerCommunityState>(
      builder: (context, state) {
        if (state is OwnerCommunityLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is OwnerCommunityLoaded) {
          final available = state.availableCommunities;
          final joined = state.joinedCommunities.where((c) {
            if (c.level != level) return false;
            if (level == 'STATE') {
              return c.stateId == widget.parentId;
            } else if (level == 'DISTRICT') {
              return c.districtId == _selectedDistrictId;
            } else if (level == 'WARD') {
              return c.wardId == _selectedWardId;
            }
            return true;
          }).toList();

          final all = [...joined, ...available];
          final seenIds = <String>{};
          final communities = all.where((c) => seenIds.add(c.id)).toList();

          if (communities.isEmpty) {
            return _buildEmptyState(level);
          }
          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
            itemCount: communities.length,
            itemBuilder: (context, index) => _CommunityCard(community: communities[index]),
          );
        }
        return _buildEmptyState(level);
      },
    );
  }

  Widget _buildEmptyState(String level) {
    final name = level == 'WARD' ? _selectedWardName : (level == 'DISTRICT' ? _selectedDistrictName : widget.parentName);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(24.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(32.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(24.r),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.groups_rounded, size: 50.sp, color: AppColors.textSecondary.withValues(alpha: 0.1)),
            ),
            SizedBox(height: 32.h),
            Text(
              StringUtils.translate('no_communities_found_in', namedArgs: {'level': level.toLowerCase() == 'state' ? StringUtils.translate('level_state', context: context) : (level.toLowerCase() == 'district' ? StringUtils.translate('level_district', context: context) : StringUtils.translate('level_ward', context: context))}, context: context),
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 18.sp, 
                fontWeight: FontWeight.w800, 
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
            SizedBox(height: 24.h),
            BouncingWrapper(
              onTap: () => _navigateToCreate(level, name ?? ''),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 20.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  StringUtils.translate('create_community_in', namedArgs: {'name': name ?? ''}, context: context),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    fontWeight: FontWeight.w700, 
                    color: Colors.white, 
                    fontSize: 14.sp,
                    height: 1.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomCreateButton() {
    final level = _getCurrentLevel();
    final name = _selectedWardName ?? _selectedDistrictName ?? widget.parentName;
    
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 32.h),
      child: BouncingWrapper(
        onTap: () => _navigateToCreate(level, name),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3), width: 1.5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline_rounded, color: AppColors.primaryBlue, size: 20.sp),
              SizedBox(width: 10.w),
              Text(
                StringUtils.translate('create_new_community', context: context),
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w800, 
                  color: AppColors.primaryBlue,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCreate(String level, String locationSummary) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateCommunityPage(
          level: level,
          stateId: widget.parentId,
          districtId: _selectedDistrictId,
          wardId: _selectedWardId,
          locationSummary: locationSummary,
        ),
      ),
    );
  }
}

class _SelectionCard extends StatelessWidget {
  final String name;
  final IconData icon;
  final VoidCallback onTap;

  const _SelectionCard({required this.name, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return BouncingWrapper(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: AppColors.accentOrange.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon, 
                color: AppColors.accentOrange, 
                size: 16.sp
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmSans(
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CommunityCard extends StatelessWidget {
  final CommunityDetailsEntity community;

  const _CommunityCard({required this.community});

  @override
  Widget build(BuildContext context) {
    return BouncingWrapper(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CommunityDetailPage(communityId: community.id),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: Row(
          children: [
            Container(
              width: 50.w,
              height: 50.w,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12.r),
                image: (community.image != null && community.image!.isNotEmpty)
                    ? DecorationImage(
                        image: NetworkImage(ApiConstants.getImageUrl(community.image)!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: community.image == null || community.image!.isEmpty
                  ? Icon(Icons.groups_3_rounded, color: AppColors.primaryBlue, size: 26.sp)
                  : null,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    community.name,
                    style: GoogleFonts.dmSans(fontSize: 15.sp, fontWeight: FontWeight.w800, color: AppColors.darkText),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    community.description ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmSans(fontSize: 12.sp, color: AppColors.greyText, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14.sp, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}
