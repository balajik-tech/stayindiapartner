import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import '../cubit/dashboard_cubit.dart';
import '../widgets/summary_cards.dart';
import '../widgets/floor_filter.dart';
import 'package:stayindia_owner/core/widgets/pattern_background.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/auth_cubit.dart';
import '../widgets/unified_header.dart';
import '../widgets/dashboard_search_bar.dart';
import '../widgets/floor_list_section.dart';
import '../widgets/dashboard_shimmer.dart';
import '../widgets/staff_dashboard_view.dart';
import 'package:stayindia_owner/features/auth/domain/entities/owner_entity.dart';

class DashboardPage extends StatefulWidget {
  final String? hostelId;
  final VoidCallback? onAddRoom;
  final bool isMultiProperty;
  final OwnerEntity? owner;

  const DashboardPage({
    super.key, 
    this.hostelId,
    this.onAddRoom,
    this.isMultiProperty = false,
    this.owner,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshData());
  }

  void _refreshData() {
    final hostelCubit = context.read<HostelCubit>();
    final hostelState = hostelCubit.state;
    
    if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
      // 10/10 RECOVERY: If IDs are empty due to the previous serialization bug, force a fresh fetch.
      final hasEmptyIds = hostelState.hostels.any((h) => h.id.isEmpty);
      if (hasEmptyIds) {
        hostelCubit.getHostels(forceRefresh: true);
        return;
      }

      final selectedIds = hostelState.selectedHostelIndices
          .where((i) => i < hostelState.hostels.length)
          .map((i) => hostelState.hostels[i].id)
          .join(',');
      
      if (selectedIds.isNotEmpty) {
        context.read<DashboardCubit>().fetchDashboardData(selectedIds);
      }
    } else {
      hostelCubit.getHostels();
    }
  }

  @override
  Widget build(BuildContext context) {

    final owner = context.select((AuthCubit cubit) {
      final state = cubit.state;
      return state is AuthAuthenticated ? state.owner : null;
    });
    
    final role = owner?.role.toLowerCase() ?? 'owner';

    if (owner != null && (role == 'cook' || role == 'cleaning_staff' || role == 'security')) {
      return StaffDashboardView(owner: owner, role: role);
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: PatternBackground(
        child: SafeArea(
          child: BlocListener<HostelCubit, HostelState>(
            listenWhen: (prev, curr) => 
              prev is HostelLoaded && curr is HostelLoaded && 
              (prev.selectedHostelIndex != curr.selectedHostelIndex || prev.selectedHostelIndices != curr.selectedHostelIndices),
            listener: (context, state) {
              _refreshData();
            },
            child: RefreshIndicator(
              onRefresh: () async => _refreshData(),
              color: AppColors.primaryBlue,
              displacement: 40,
              child: BlocBuilder<DashboardCubit, DashboardState>(
                buildWhen: (prev, curr) => prev is DashboardLoading != curr is DashboardLoading,
                builder: (context, state) {
                  if (state is DashboardLoading) {
                    return const DashboardShimmer();
                  }
                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    slivers: [
                      const SliverToBoxAdapter(child: UnifiedHeader()),
                      
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: const SummaryCardsSection(),
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: BlocBuilder<DashboardCubit, DashboardState>(
                            buildWhen: (prev, curr) => 
                              prev.selectedFloorIndex != curr.selectedFloorIndex || 
                              (prev is DashboardLoaded && curr is DashboardLoaded && prev.data.occupancy != curr.data.occupancy),
                            builder: (context, state) {
                              List<String> floors = ['all_floors'.tr()];
                              if (state is DashboardLoaded) {
                                floors.addAll(state.data.occupancy.floors.map((e) => e.floorName));
                              }
                              return FloorFilter(
                                floors: floors,
                                selectedIndex: state.selectedFloorIndex + 1,
                                onSelected: (index) => context.read<DashboardCubit>().selectFloor(index - 1),
                              );
                            },
                          ),
                        ),
                      ),

                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
                          child: const DashboardSearchBar(),
                        ),
                      ),
                      
                      SliverToBoxAdapter(child: SizedBox(height: 4.h)),

                      const FloorListSection(),
                      
                      SliverToBoxAdapter(child: SizedBox(height: 100.h)),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
