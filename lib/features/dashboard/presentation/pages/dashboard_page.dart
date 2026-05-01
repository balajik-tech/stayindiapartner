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
import 'package:stayindia_owner/features/dashboard/domain/entities/occupancy_summary.dart' as entity;
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:flutter/services.dart';
import 'package:stayindia_owner/features/navigation/presentation/pages/main_navigation_page.dart';
import 'package:stayindia_owner/features/notifications/presentation/pages/notifications_page.dart';


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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: BlocListener<HostelCubit, HostelState>(
          listenWhen: (prev, curr) => 
            prev is HostelLoaded && curr is HostelLoaded && 
            prev.selectedHostelIndex != curr.selectedHostelIndex,
          listener: (context, state) {
            _refreshData();
          },
          child: RefreshIndicator(
            onRefresh: () async => _refreshData(),
            color: AppColors.primaryBlue,
            displacement: 40,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              slivers: [
                // 1. Header
                const SliverToBoxAdapter(child: _UnifiedHeader()),
                
                // 2. Stat Cards
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: const SummaryCardsSection(),
                  ),
                ),

                // 3. Floor Filter Chips
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 12.h),
                    child: BlocBuilder<DashboardCubit, DashboardState>(
                      buildWhen: (prev, curr) => 
                        prev.runtimeType != curr.runtimeType ||
                        prev.selectedFloorIndex != curr.selectedFloorIndex || 
                        (prev is DashboardLoaded && curr is DashboardLoaded && prev.data.occupancy != curr.data.occupancy),
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
                    ),
                  ),
                ),

                // 4. Search Bar (Restored)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: const _SearchBarWidget(),
                  ),
                ),
                
                SliverToBoxAdapter(child: SizedBox(height: 20.h)),

                // 5. Floor Sections
                const _FloorListSection(),
                
                SliverToBoxAdapter(child: SizedBox(height: 100.h)),
              ],
            ),
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
    return BlocBuilder<HostelCubit, HostelState>(
      builder: (context, state) {
        String hostelName = '...';
        String hostelType = '';
        
        if (state is HostelLoaded && state.hostels.isNotEmpty) {
          final hostel = state.hostels[state.selectedHostelIndex];
          hostelName = hostel.name;
          hostelType = hostel.propertyTag ?? hostel.hostelType.replaceAll('_', ' ');
        }


        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
          ),
          padding: EdgeInsets.fromLTRB(12.w, 12.h, 16.w, 12.h),
          child: Row(
            children: [
              // 1. Menu Icon
              IconButton(
                onPressed: () => MainNavigationPage.scaffoldKey.currentState?.openDrawer(),
                icon: Icon(Icons.menu_rounded, color: const Color(0xFF1E293B), size: 24.sp),
              ),
              SizedBox(width: 4.w),
              
              // 2. Hostel Icon
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7ED),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Icons.apartment_rounded, color: Colors.orange, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              
              // 3. Hostel Name & Type
              Expanded(
                child: GestureDetector(
                  onTap: () => _showSwitchHostelSheet(context),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              hostelName,
                              style: TextStyle(
                                color: const Color(0xFF1E293B),
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(Icons.keyboard_arrow_down_rounded, color: const Color(0xFF64748B), size: 16.sp),
                        ],
                      ),
                      Text(
                        hostelType.toUpperCase(),
                        style: TextStyle(
                          color: const Color(0xFF94A3B8),
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              
              // 4. Notifications
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsPage()),
                  );
                },
                child: Stack(
                  children: [
                    Container(
                      width: 38.w,
                      height: 38.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.notifications_none_rounded, color: const Color(0xFF1E293B), size: 20.sp),
                    ),
                    Positioned(
                      right: 8.w,
                      top: 8.h,
                      child: Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
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

  void _showSwitchHostelSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocBuilder<HostelCubit, HostelState>(
        builder: (context, state) {
          if (state is! HostelLoaded) return const SizedBox.shrink();
          
          return Container(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 24.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 32.w,
                    height: 3.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(1.5.r),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  'Switch Property',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 12.h),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 0.5.sh),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: state.hostels.length,
                    itemBuilder: (context, index) {
                      final hostel = state.hostels[index];
                      final isSelected = index == state.selectedHostelIndex;
                      return Container(
                        margin: EdgeInsets.only(bottom: 8.h),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFFF1F5F9) : Colors.white,
                          border: Border.all(
                            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                          ),
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: ListTile(
                          onTap: () {
                            context.read<HostelCubit>().selectHostel(index);
                            Navigator.pop(context);
                          },
                          dense: true,
                          leading: Container(
                            padding: EdgeInsets.all(8.r),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFF1F5F9),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.apartment_rounded, 
                              color: isSelected ? Colors.white : const Color(0xFF64748B),
                              size: 18.sp,
                            ),
                          ),
                          title: Text(
                            hostel.name,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF1E293B),
                            ),
                          ),
                          trailing: isSelected 
                              ? Icon(Icons.check_circle_rounded, color: const Color(0xFF2563EB), size: 20.sp) 
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
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
          final hostelState = context.watch<HostelCubit>().state;
          if (hostelState is HostelLoaded && hostelState.hostels.isEmpty) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.apartment_rounded, size: 80.sp, color: Colors.grey.shade300),
                    SizedBox(height: 24.h),
                    Text(
                      'No Hostels Added',
                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Add a hostel to start managing it here.',
                      style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            );
          }
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
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final floor = displayFloors[index];
                final filteredRooms = floor.rooms.where((room) {
                  if (state.selectedMetric != null) {
                    bool matchesMetric = false;
                    switch (state.selectedMetric) {
                      case 'total':
                        matchesMetric = true;
                        break;
                      case 'free':
                        matchesMetric = room.beds.any((b) => b.status.toLowerCase() == 'free');
                        break;
                      case 'occupied':
                        matchesMetric = room.beds.any((b) => b.status.toLowerCase() == 'occupied');
                        break;
                      case 'notice':
                        matchesMetric = room.beds.any((b) => b.status.toLowerCase() == 'notice');
                        break;
                      case 'overdue':
                        matchesMetric = room.beds.any((b) => b.status.toLowerCase() == 'overdue');
                        break;
                      case 'inside':
                        matchesMetric = room.beds.any((b) => b.status.toLowerCase() == 'inside');
                        break;
                      case 'outside':
                        matchesMetric = room.beds.any((b) => b.status.toLowerCase() == 'outside');
                        break;
                      case 'away':
                        matchesMetric = room.beds.any((b) => b.status.toLowerCase() == 'away' || b.status.toLowerCase() == 'unknown');
                        break;
                      default:
                        matchesMetric = true;
                    }
                    if (!matchesMetric) return false;
                  }

                  // 2. Search Filter
                  if (query.isEmpty) return true;
                  final roomNum = room.roomNumber.toLowerCase();
                  final hasMatchingTenant = room.beds.any((bed) => 
                    (bed.tenantName?.toLowerCase().contains(query) ?? false));
                  return roomNum.contains(query) || hasMatchingTenant;
                }).toList();

                if (filteredRooms.isEmpty && query.isNotEmpty) return const SizedBox.shrink();

                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: FloorAccordion(
                    title: floor.floorName,
                    bedInfo: floor.bedInfo,
                    isInitialExpanded: index == 0 || query.isNotEmpty,
                    isGridView: state.isGridView,
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
                        isAway: b.isAway,
                      )).toList(),
                      roomType: room.roomType,
                      room: room,
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
}


class _SearchBarWidget extends StatelessWidget {
  const _SearchBarWidget();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        return Row(
          children: [
            Expanded(
              child: Container(
                height: 48.h,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: const Color(0xFF64748B), size: 18.sp),
                    Expanded(
                      child: TextField(
                        onChanged: (value) => context.read<DashboardCubit>().updateSearchQuery(value),
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          hintText: 'Search room, tenant...',
                          hintStyle: TextStyle(color: const Color(0xFF94A3B8), fontSize: 13.sp),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 10.w),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 10.w),
            _ViewModeToggle(
              isGridView: state.isGridView,
              onChanged: (isGrid) => context.read<DashboardCubit>().toggleViewType(isGrid),
            ),
          ],
        );
      },
    );
  }
}

class _ViewModeToggle extends StatelessWidget {
  final bool isGridView;
  final Function(bool) onChanged;

  const _ViewModeToggle({required this.isGridView, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96.w,
      height: 44.h,
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(21.r),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.elasticOut,
            alignment: isGridView ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: 42.w,
              height: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF1E293B),
                borderRadius: BorderRadius.circular(18.r),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: BouncingWrapper(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onChanged(true);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.transparent,
                    child: Icon(
                      Icons.grid_view_rounded,
                      size: 19.sp,
                      color: isGridView ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: BouncingWrapper(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onChanged(false);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.transparent,
                    child: Icon(
                      Icons.list_rounded,
                      size: 24.sp,
                      color: !isGridView ? Colors.white : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
