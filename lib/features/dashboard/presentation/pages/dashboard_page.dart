import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import '../cubit/dashboard_cubit.dart';
import '../widgets/summary_cards.dart';
import '../widgets/floor_filter.dart';
import '../widgets/floor_accordion.dart';
import '../widgets/room_card.dart';
import './rent_due_page.dart';
import 'package:stayindia_owner/features/notifications/presentation/pages/notifications_page.dart';
import 'package:stayindia_owner/features/dashboard/presentation/widgets/dashboard_secondary_stats_row.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/occupancy_summary.dart' as entity;
import 'package:stayindia_owner/features/navigation/presentation/pages/main_navigation_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  void _refreshData() {
    final hostelState = context.read<HostelCubit>().state;
    if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
      final hostelId = hostelState.hostels[hostelState.selectedHostelIndex].id;
      context.read<DashboardCubit>().fetchDashboardData(hostelId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFBFBFE),
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => _refreshData(),
          color: AppColors.primaryBlue,
          displacement: 40,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              
              SliverToBoxAdapter(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const _UnifiedHeader(),
                    Positioned(
                      bottom: -28.h, 
                      left: 16.w,
                      right: 16.w,
                      child: const _SearchBarWidget(),
                    ),
                  ],
                ),
              ),
              
              
              SliverToBoxAdapter(child: SizedBox(height: 48.h)),
              
              
              const _FloorListSection(),
              
              
              SliverToBoxAdapter(child: SizedBox(height: 100.h)),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnifiedHeader extends StatelessWidget {
  const _UnifiedHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF0A2647),
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 56.h), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => MainNavigationPage.scaffoldKey.currentState?.openDrawer(),
                      child: Container(
                        padding: EdgeInsets.all(8.r),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Icon(Icons.menu_rounded, color: Colors.white, size: 22.sp),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(Icons.apartment_rounded, color: Colors.white, size: 24.sp),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STAY INDIA',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22.sp,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                          Text(
                            'PREMIUM HOSTEL',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsPage()),
                  );
                },
                child: Stack(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.orange, width: 1.5),
                      ),
                      child: Icon(Icons.notifications_none_rounded, color: Colors.white, size: 28.sp),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 10.r,
                        height: 10.r,
                        decoration: const BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          
          const _SummaryCardsSection(),
          
          SizedBox(height: 12.h),
          
          
          const DashboardSecondaryStatsRow(),
          
          SizedBox(height: 16.h),
          
          
          const _FloorFilterChips(),
        ],
      ),
    );
  }
}

class _SearchBarWidget extends StatelessWidget {
  const _SearchBarWidget();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      buildWhen: (prev, curr) => prev.isGridView != curr.isGridView,
      builder: (context, state) {
        return Container(
          height: 56.h,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, color: Colors.orange, size: 22.sp),
              Expanded(
                child: TextField(
                  onChanged: (value) => context.read<DashboardCubit>().updateSearchQuery(value),
                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: 'Search beds or tenants',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                  ),
                ),
              ),
              Container(
                height: 36.h,
                padding: EdgeInsets.all(2.r),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(18.r),
                ),
                child: Row(
                  children: [
                    _ViewToggleIcon(
                      isSelected: state.isGridView,
                      icon: Icons.grid_view_rounded,
                      onTap: () => context.read<DashboardCubit>().toggleViewType(true),
                    ),
                    _ViewToggleIcon(
                      isSelected: !state.isGridView,
                      icon: Icons.list_rounded,
                      onTap: () => context.read<DashboardCubit>().toggleViewType(false),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ViewToggleIcon extends StatelessWidget {
  final bool isSelected;
  final IconData icon;
  final VoidCallback onTap;

  const _ViewToggleIcon({required this.isSelected, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: double.infinity,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0A2647) : Colors.transparent,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.white : Colors.grey.shade400,
          size: 18.sp,
        ),
      ),
    );
  }
}

class _SummaryCardsSection extends StatelessWidget {
  const _SummaryCardsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      buildWhen: (prev, curr) {
        if (prev is DashboardLoaded && curr is DashboardLoaded) {
          return prev.data.occupancy != curr.data.occupancy;
        }
        return prev.runtimeType != curr.runtimeType;
      },
      builder: (context, state) {
        final bool isLoading = state is DashboardLoading;
        final data = state is DashboardLoaded ? state.data.occupancy : null;

        return SizedBox(
          height: 80.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.zero,
            physics: const BouncingScrollPhysics(),
            children: [
              SummaryCard(
                count: isLoading ? '...' : (data?.totalBeds.toString() ?? '0'),
                label: 'TOTAL',
                backgroundColor: const Color(0xFF1E325C), 
                textColor: Colors.white,
                icon: Icons.hotel_rounded,
              ),
              SizedBox(width: 12.w),
              SummaryCard(
                count: isLoading ? '...' : (data?.occupiedBeds.toString() ?? '0'),
                label: 'ACTIVE',
                backgroundColor: const Color(0xFFFF7000), 
                textColor: Colors.white,
                icon: Icons.person_rounded,
              ),
              SizedBox(width: 12.w),
              SummaryCard(
                count: isLoading ? '...' : (data?.freeBeds.toString() ?? '0'),
                label: 'FREE',
                backgroundColor: const Color(0xFF3498DB), 
                textColor: Colors.white,
                icon: Icons.hotel_rounded,
              ),
              SizedBox(width: 12.w),
              SummaryCard(
                count: isLoading ? '...' : (data?.noticeBeds.toString() ?? '0'),
                label: 'NOTICE',
                backgroundColor: const Color(0xFFF1C40F), 
                textColor: Colors.white,
                icon: Icons.access_time_filled_rounded,
              ),
              SizedBox(width: 12.w),
              SummaryCard(
                count: isLoading ? '...' : (data?.overdueBeds.toString() ?? '0'),
                label: 'OVERDUE',
                backgroundColor: Colors.red.shade600, 
                textColor: Colors.white,
                icon: Icons.assignment_late_rounded,
                onTap: () {
                  final hostelState = context.read<HostelCubit>().state;
                  if (hostelState is HostelLoaded && hostelState.hostels.isNotEmpty) {
                    final hostelId = hostelState.hostels[hostelState.selectedHostelIndex].id;
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RentDuePage(hostelId: hostelId),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FloorFilterChips extends StatelessWidget {
  const _FloorFilterChips();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      buildWhen: (prev, curr) => prev.selectedFloorIndex != curr.selectedFloorIndex || 
          prev.runtimeType != curr.runtimeType ||
          (prev is DashboardLoaded && curr is DashboardLoaded && prev.data.occupancy.floors.length != curr.data.occupancy.floors.length),
      builder: (context, state) {
        List<String> floors = ['All Floors'];
        if (state is DashboardLoaded) {
          floors.addAll(state.data.occupancy.floors.map((e) => e.floorName));
        }

        return FloorFilter(
          floors: floors,
          selectedIndex: state.selectedFloorIndex + 1,
          onSelected: (index) => context.read<DashboardCubit>().selectFloor(index - 1),
        );
      },
    );
  }
}

class _FloorListSection extends StatelessWidget {
  const _FloorListSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      buildWhen: (prev, curr) {
        if (prev is DashboardLoading && curr is DashboardLoaded) return true;
        if (prev is DashboardLoaded && curr is DashboardLoaded) {
          return prev.data.occupancy != curr.data.occupancy || 
                 prev.selectedFloorIndex != curr.selectedFloorIndex ||
                 prev.searchQuery != curr.searchQuery ||
                 prev.isGridView != curr.isGridView;
        }
        return prev.runtimeType != curr.runtimeType;
      },
      builder: (context, state) {
        if (state is DashboardLoading) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
          );
        }

        if (state is DashboardError) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text(state.message, style: const TextStyle(color: Colors.red))),
          );
        }

        if (state is! DashboardLoaded) {
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        final data = state.data.occupancy;
        final query = state.searchQuery.toLowerCase();
        
        final List<entity.FloorData> displayFloors = state.selectedFloorIndex == -1 
            ? data.floors 
            : (state.selectedFloorIndex < data.floors.length ? [data.floors[state.selectedFloorIndex]] : []);

        if (displayFloors.isEmpty) {
          return const SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text('No floors found')),
          );
        }

        return SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final floor = displayFloors[index];
                final filteredRooms = floor.rooms.where((room) {
                  if (query.isEmpty) return true;
                  final roomNum = room.roomNumber.toLowerCase();
                  final hasMatchingTenant = room.beds.any((bed) => 
                    (bed.tenantName?.toLowerCase().contains(query) ?? false));
                  return roomNum.contains(query) || hasMatchingTenant;
                }).toList();

                if (filteredRooms.isEmpty && query.isNotEmpty) return const SizedBox.shrink();

                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: FloorAccordion(
                    title: floor.floorName,
                    bedInfo: floor.bedInfo,
                    isInitialExpanded: index == 0 || query.isNotEmpty,
                    isGridView: state.isGridView,
                    onDelete: () => _showDeleteFloorConfirmation(context, floor.floorName, filteredRooms.map((r) => r.id).toList()),
                    rooms: filteredRooms.map<Widget>((room) => RoomCard(
                      id: room.id,
                      roomNumber: room.roomNumber,
                      sharingType: room.sharingType,
                      occupancy: room.occupancy,
                      isGridView: state.isGridView,
                      rent: room.rent,
                      dailyRent: room.dailyRent,
                      beds: room.beds.map((b) => entity.BedInfo(
                        bedNumber: b.bedNumber, 
                        status: b.status,
                        tenantName: b.tenantName,
                        tenantAvatar: b.tenantAvatar,
                        tenantId: b.tenantId,
                      )).toList(),
                    )).toList(),
                  ),
                );
              },
              childCount: displayFloors.length,
            ),
          ),
        );
      },
    );
  }

  void _showDeleteFloorConfirmation(BuildContext context, String floorName, List<String> roomIds) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24.r)),
          title: Text(
            'Delete Entire Floor?',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w900, color: const Color(0xFF1E325C)),
          ),
          content: Text(
            'Are you sure you want to delete all ${roomIds.length} rooms on $floorName? This action is permanent and will remove all associated beds.',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w700, fontSize: 14.sp),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final cubit = context.read<DashboardCubit>();
                final hostelId = context.read<HostelCubit>().state is HostelLoaded 
                    ? (context.read<HostelCubit>().state as HostelLoaded).hostels[(context.read<HostelCubit>().state as HostelLoaded).selectedHostelIndex].id
                    : null;
                
                if (hostelId == null) return;

                Navigator.pop(context); 

                try {
                  await cubit.deleteRoomsBulk(roomIds, hostelId);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('$floorName deleted successfully'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to delete floor: $e'),
                        backgroundColor: Colors.red,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
              ),
              child: Text(
                'Delete Floor',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14.sp),
              ),
            ),
          ],
        );
      },
    );
  }
}


