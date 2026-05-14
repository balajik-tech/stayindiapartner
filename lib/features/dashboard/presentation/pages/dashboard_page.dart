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
import 'package:stayindia_owner/core/widgets/pattern_background.dart';
import 'package:flutter/services.dart';
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
      backgroundColor: AppColors.scaffoldBackground,
      body: PatternBackground(
        child: SafeArea(
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
                  const SliverToBoxAdapter(child: _UnifiedHeader()),
                  
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 8.h, bottom: 2.h),
                      child: const SummaryCardsSection(),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.zero,
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

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: const _SearchBarWidget(),
                    ),
                  ),
                  
                  SliverToBoxAdapter(child: SizedBox(height: 4.h)),

                  const _FloorListSection(),
                  
                  SliverToBoxAdapter(child: SizedBox(height: 100.h)),
                ],
              ),
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

        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
          color: AppColors.backgroundPrimary,
          child: Row(
            children: [
              BouncingWrapper(
                onTap: () => _showSwitchHostelSheet(context),
                child: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                  ),
                  child: Icon(Icons.apartment_rounded, color: AppColors.accentOrange, size: 18.sp),
                ),
              ),
              
              SizedBox(width: 12.w),
              
              GestureDetector(
                onTap: () => _showSwitchHostelSheet(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.more_horiz_rounded, color: AppColors.textSecondary, size: 16.sp),
                    Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary, size: 14.sp),
                  ],
                ),
              ),

              const Spacer(),

              BouncingWrapper(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsPage()),
                  );
                },
                child: Container(
                  width: 38.w,
                  height: 38.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(Icons.notifications_none_rounded, color: const Color(0xFF0F172A), size: 20.sp),
                      Positioned(
                        right: 10.w,
                        top: 10.h,
                        child: Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: BoxDecoration(
                            color: AppColors.accentOrange,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 1.5),
                          ),
                        ),
                      ),
                    ],
                  ),
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
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
            decoration: BoxDecoration(
              color: AppColors.backgroundPrimary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  'Switch Property',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 16.h),
                ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: 0.6.sh),
                  child: ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.zero,
                    itemCount: state.hostels.length,
                    itemBuilder: (context, index) {
                      final hostel = state.hostels[index];
                      final isSelected = index == state.selectedHostelIndex;
                      return BouncingWrapper(
                        onTap: () {
                          context.read<HostelCubit>().selectHostel(index);
                          Navigator.pop(context);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.05) : Colors.transparent,
                            border: Border.all(
                              color: isSelected ? AppColors.primaryBlue : AppColors.border,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.r),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppColors.primaryBlue.withValues(alpha: 0.1) : AppColors.backgroundSecondary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.apartment_rounded, 
                                  color: isSelected ? AppColors.primaryBlue : AppColors.textSecondary,
                                  size: 22.sp,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Text(
                                  hostel.name,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    color: isSelected ? AppColors.primaryBlue : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                Icon(Icons.check_circle_rounded, color: AppColors.primaryBlue, size: 24.sp),
                            ],
                          ),
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
                    Icon(Icons.apartment_rounded, size: 80.sp, color: AppColors.textSecondary.withValues(alpha: 0.2)),
                    SizedBox(height: 24.h),
                    Text(
                      'No Hostels Added',
                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Add a hostel to start managing it here.',
                      style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
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


class _SearchBarWidget extends StatefulWidget {
  const _SearchBarWidget();

  @override
  State<_SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<_SearchBarWidget> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        return Row(
          children: [
            Expanded(
              child: AnimatedScale(
                scale: _isFocused ? 1.01 : 1.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  height: 56.h,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  decoration: BoxDecoration(
                    color: _isFocused ? Colors.white : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(18.r),
                    border: Border.all(
                      color: _isFocused ? AppColors.primaryBlue : AppColors.border.withValues(alpha: 0.5),
                      width: _isFocused ? 1.8 : 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: _isFocused ? 0.08 : 0.04),
                        blurRadius: _isFocused ? 16 : 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        child: Icon(
                          Icons.search_rounded, 
                          color: _isFocused ? AppColors.primaryBlue : AppColors.textSecondary.withValues(alpha: 0.7), 
                          size: 24.sp
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          focusNode: _focusNode,
                          onChanged: (value) => context.read<DashboardCubit>().updateSearchQuery(value),
                          style: TextStyle(
                            fontSize: 15.sp, 
                            fontWeight: FontWeight.w700, 
                            color: AppColors.textPrimary,
                            letterSpacing: -0.3,
                          ),
                          decoration: InputDecoration(
                            hintText: 'Search room, tenant...',
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary.withValues(alpha: 0.5), 
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            filled: false,
                            fillColor: Colors.transparent,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(horizontal: 12.w),
                          ),
                        ),
                      ),
                      if (state.searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            context.read<DashboardCubit>().updateSearchQuery('');
                            _focusNode.unfocus();
                          },
                          child: Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20.sp),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
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
      width: 100.w,
      height: 48.h,
      padding: EdgeInsets.all(5.r),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutBack,
            alignment: isGridView ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: 44.w,
              height: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(20.r),
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
                      size: 20.sp,
                      color: isGridView ? Colors.white : AppColors.textSecondary,
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
                      color: !isGridView ? Colors.white : AppColors.textSecondary,
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

