import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/bouncing_wrapper.dart';
import '../../../../core/widgets/shimmer_loading.dart';
import '../cubit/association_cubit.dart';
import '../cubit/owner_community_cubit.dart';
import '../../domain/entities/community_entity.dart';
import 'community_detail_page.dart';
import 'create_community_page.dart';

class AssociationSelectionPage extends StatefulWidget {
  const AssociationSelectionPage({super.key});

  @override
  State<AssociationSelectionPage> createState() =>
      _AssociationSelectionPageState();
}

class _AssociationSelectionPageState extends State<AssociationSelectionPage> {
  String? selectedState;
  String? selectedDistrict;
  String? selectedWard;
  String? selectedLocal;
  String currentLevel = 'STATE';

  @override
  void initState() {
    super.initState();
    context.read<AssociationCubit>().loadStates();
    _triggerDiscovery();
  }

  void _triggerDiscovery() {
    context.read<OwnerCommunityCubit>().discoverCommunities(
      level: currentLevel,
      stateId: selectedState,
      districtId: selectedDistrict,
      wardId: selectedWard,
      localityId: selectedLocal,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Discover Communities',
          style: GoogleFonts.outfit(
            color: AppColors.darkText,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: AppColors.darkText),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: BlocBuilder<OwnerCommunityCubit, OwnerCommunityState>(
              builder: (context, state) {
                if (state is OwnerCommunityLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is OwnerCommunityLoaded) {
                  final communities = state.availableCommunities;
                  if (communities.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildCommunityList(communities);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return BlocBuilder<AssociationCubit, AssociationState>(
      builder: (context, state) {
        if (state is AssociationError) {
          return Container(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'Failed to load locations: ${state.message}',
                    style: TextStyle(color: Colors.red, fontSize: 12.sp),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      context.read<AssociationCubit>().loadStates(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final associationState = state is AssociationLoaded ? state : null;
        final isSubLoading = state is AssociationLoaded && state.isSubLoading;

        return Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(32.r)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDropdown(
                label: 'State',
                value: selectedState,
                items: associationState?.states ?? [],
                isLoading: state is AssociationLoading,
                onChanged: (val) {
                  setState(() {
                    selectedState = val;
                    selectedDistrict = null;
                    selectedWard = null;
                    selectedLocal = null;
                    currentLevel = 'STATE';
                  });
                  if (val != null) {
                    context.read<AssociationCubit>().loadDistricts(val);
                  }
                  _triggerDiscovery();
                },
              ),
              if (selectedState != null) ...[
                SizedBox(height: 12.h),
                _buildDropdown(
                  label: 'District',
                  value: selectedDistrict,
                  items: associationState?.districts ?? [],
                  isLoading:
                      isSubLoading &&
                      (associationState?.districts?.isEmpty ?? true),
                  onChanged: (val) {
                    setState(() {
                      selectedDistrict = val;
                      selectedWard = null;
                      selectedLocal = null;
                      currentLevel = 'DISTRICT';
                    });
                    if (val != null) {
                      context.read<AssociationCubit>().loadWards(val);
                    }
                    _triggerDiscovery();
                  },
                ),
              ],
              if (selectedDistrict != null) ...[
                SizedBox(height: 12.h),
                _buildDropdown(
                  label: 'Ward / Zone',
                  value: selectedWard,
                  items: associationState?.wards ?? [],
                  isLoading:
                      isSubLoading &&
                      (associationState?.wards?.isEmpty ?? true),
                  onChanged: (val) {
                    setState(() {
                      selectedWard = val;
                      selectedLocal = null;
                      currentLevel = 'WARD';
                    });
                    if (val != null) {
                      context.read<AssociationCubit>().loadLocals(val);
                    }
                    _triggerDiscovery();
                  },
                ),
              ],
              if (selectedWard != null) ...[
                SizedBox(height: 12.h),
                _buildDropdown(
                  label: 'Local Association',
                  value: selectedLocal,
                  items: associationState?.locals ?? [],
                  isLoading:
                      isSubLoading &&
                      (associationState?.locals?.isEmpty ?? true),
                  onChanged: (val) {
                    setState(() {
                      selectedLocal = val;
                      currentLevel = 'LOCAL';
                    });
                    _triggerDiscovery();
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<dynamic> items,
    required ValueChanged<String?> onChanged,
    bool isLoading = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.greyText,
          ),
        ),
        SizedBox(height: 6.h),
        isLoading && items.isEmpty
            ? const DropdownSkeleton()
            : Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: AppColors.backgroundGrey,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    isExpanded: true,
                    hint: Text(
                      'Select $label',
                      style: GoogleFonts.outfit(fontSize: 14.sp),
                    ),
                    items: items.map((item) {
                      return DropdownMenuItem<String>(
                        value: item['_id'],
                        child: Text(
                          item['name'],
                          style: GoogleFonts.outfit(fontSize: 14.sp),
                        ),
                      );
                    }).toList(),
                    onChanged: onChanged,
                  ),
                ),
              ),
      ],
    );
  }

  Widget _buildCommunityList(List<CommunityDetailsEntity> communities) {
    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      itemCount: communities.length,
      itemBuilder: (context, index) {
        final community = communities[index];
        return _DiscoveryCard(community: community);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.explore_off_rounded,
            size: 64.sp,
            color: Colors.grey.shade200,
          ),
          SizedBox(height: 16.h),
          Text(
            'No communities found for this level',
            style: GoogleFonts.outfit(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.greyText,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () => _showCreateCommunityDialog(),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Create Community',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateCommunityDialog() {
    final associationState =
        context.read<AssociationCubit>().state as AssociationLoaded;
    String summary = '';

    if (selectedState != null) {
      final stateName = associationState.states.firstWhere(
        (s) => s['_id'] == selectedState,
      )['name'];
      summary = stateName;
    }
    if (selectedDistrict != null) {
      final distName = associationState.districts!.firstWhere(
        (d) => d['_id'] == selectedDistrict,
      )['name'];
      summary += ' → $distName';
    }
    if (selectedWard != null) {
      final wardName = associationState.wards!.firstWhere(
        (w) => w['_id'] == selectedWard,
      )['name'];
      summary += ' → $wardName';
    }
    if (selectedLocal != null) {
      final localName = associationState.locals!.firstWhere(
        (l) => l['_id'] == selectedLocal,
      )['name'];
      summary += ' → $localName';
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateCommunityPage(
          level: currentLevel,
          stateId: selectedState,
          districtId: selectedDistrict,
          wardId: selectedWard,
          localityId: selectedLocal,
          locationSummary: summary.isEmpty ? 'National' : summary,
        ),
      ),
    );
  }
}

class _DiscoveryCard extends StatelessWidget {
  final CommunityDetailsEntity community;

  const _DiscoveryCard({required this.community});

  @override
  Widget build(BuildContext context) {
    final isPending = community.status == 'PENDING';

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
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.01),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16.r),
                image: community.image != null
                    ? DecorationImage(
                        image: CachedNetworkImageProvider(community.image!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: community.image == null
                  ? Icon(
                      Icons.groups_3_rounded,
                      color: AppColors.primaryBlue,
                      size: 28.sp,
                    )
                  : null,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    community.name,
                    style: GoogleFonts.outfit(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkText,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          community.level ?? 'LOCAL',
                          style: GoogleFonts.outfit(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '${community.memberCount} members',
                        style: GoogleFonts.outfit(
                          fontSize: 12.sp,
                          color: AppColors.greyText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: isPending
                  ? null
                  : () {
                      context.read<OwnerCommunityCubit>().joinCommunity(
                        community.id,
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: isPending
                    ? Colors.grey.shade100
                    : AppColors.primaryBlue,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.w),
              ),
              child: Text(
                isPending ? 'Requested' : 'Join',
                style: GoogleFonts.outfit(
                  color: isPending ? AppColors.greyText : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
