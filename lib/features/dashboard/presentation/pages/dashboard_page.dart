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
import 'package:stayindia_owner/core/constants/ui_constants.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/occupancy_summary.dart' as entity;
import 'rent_due_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
  }

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
      child: RefreshIndicator(
          onRefresh: () async => _refreshData(),
          color: AppColors.primaryBlue,
          edgeOffset: 120,
          child: BlocBuilder<DashboardCubit, DashboardState>(
            builder: (context, state) {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                slivers: [
                  SliverToBoxAdapter(
                    child: _PremiumHeader(state: context.watch<HostelCubit>().state),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 24.h)),
                  SliverToBoxAdapter(
                    child: _StaggeredEntry(
                      delayMs: 200,
                      child: _DashboardSummarySection(state: state),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 32.h)),
                  SliverToBoxAdapter(
                    child: _StaggeredEntry(
                      delayMs: 400,
                      child: _DashboardFilterSection(state: state),
                    ),
                  ),
                  SliverToBoxAdapter(child: SizedBox(height: 32.h)),
                  SliverToBoxAdapter(
                    child: _StaggeredEntry(
                      delayMs: 500,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Text(
                          'Occupancy Status',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w900,
                            color: AppColors.darkText,
                            letterSpacing: -0.8,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _DashboardContentSection(state: state),
                  UIConstants.bottomPaddingSliver(context),
                ],
              );
            },
          ),
        ),
      );
  }
}

class _PremiumHeader extends StatelessWidget {
  final HostelState state;
  const _PremiumHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    final String hostelName = (state is HostelLoaded && (state as HostelLoaded).hostels.isNotEmpty)
        ? (state as HostelLoaded).hostels[(state as HostelLoaded).selectedHostelIndex].name
        : 'Stay India';
    
    final String? city = (state is HostelLoaded && (state as HostelLoaded).hostels.isNotEmpty)
        ? (state as HostelLoaded).hostels[(state as HostelLoaded).selectedHostelIndex].city
        : null;

    return Container(
      constraints: BoxConstraints(minHeight: 200.h),
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1A2151), Color(0xFF3359AD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 48.h, 24.w, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () => Scaffold.of(context).openDrawer(),
                child: Container(
                  padding: EdgeInsets.all(8.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.menu_rounded, color: Colors.white, size: 24.sp),
                ),
              ),
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.notifications_none_rounded, color: Colors.white, size: 24.sp),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hostelName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (city != null)
                      Row(
                        children: [
                          Icon(Icons.location_on_rounded, color: Colors.white.withValues(alpha: 0.6), size: 14.sp),
                          SizedBox(width: 4.w),
                          Text(
                            city,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const HostelSelectionSheet(),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(25.r),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Switch',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13.sp),
                      ),
                      Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 18.sp),
                    ],
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

class _DashboardSummarySection extends StatelessWidget {
  final DashboardState state;
  const _DashboardSummarySection({required this.state});

  @override
  Widget build(BuildContext context) {
    final bool isLoading = state is DashboardLoading;
    final data = state is DashboardLoaded ? (state as DashboardLoaded).data.occupancy : null;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Row(
        children: [
          SummaryCard(
            count: isLoading ? '...' : (data?.totalBeds.toString() ?? '0'),
            label: 'Total',
            backgroundColor: const Color(0xFF4C6EF5),
            textColor: Colors.white,
          ),
          SizedBox(width: 16.w),
          SummaryCard(
            count: isLoading ? '...' : (data?.freeBeds.toString() ?? '0'),
            label: 'Free',
            backgroundColor: const Color(0xFF099268),
            textColor: Colors.white,
          ),
          SizedBox(width: 16.w),
          SummaryCard(
            count: isLoading ? '...' : (data?.occupiedBeds.toString() ?? '0'),
            label: 'Occupied',
            backgroundColor: const Color(0xFF1971C2),
            textColor: Colors.white,
          ),
          SizedBox(width: 16.w),
          SummaryCard(
            count: isLoading ? '...' : (data?.noticeBeds.toString() ?? '0'),
            label: 'Notice',
            backgroundColor: const Color(0xFFF08C00),
            textColor: Colors.white,
          ),
          SizedBox(width: 16.w),
          SummaryCard(
            count: isLoading ? '...' : (data?.awayBeds.toString() ?? '0'),
            label: 'Away',
            backgroundColor: Colors.orange.shade700,
            textColor: Colors.white,
          ),
          SizedBox(width: 16.w),
          SummaryCard(
            count: isLoading ? '...' : (state is DashboardLoaded ? (state as DashboardLoaded).data.dailyOperations.overdueRent.count.toString() : '0'),
            label: 'Overdue',
            backgroundColor: const Color(0xFFE03131),
            textColor: Colors.white,
            onTap: () {
              if (state is DashboardLoaded) {
                 final hostelState = context.read<HostelCubit>().state;
                 if (hostelState is HostelLoaded) {
                   final hostelId = hostelState.hostels[hostelState.selectedHostelIndex].id;
                   Navigator.push(
                     context,
                     MaterialPageRoute(builder: (context) => RentDuePage(hostelId: hostelId)),
                   );
                 }
              }
            },
          ),
        ],
      ),
    );
  }
}

class _DashboardFilterSection extends StatelessWidget {
  final DashboardState state;
  const _DashboardFilterSection({required this.state});

  @override
  Widget build(BuildContext context) {
    List<String> floors = ['All'];
    if (state is DashboardLoaded) {
      floors.addAll((state as DashboardLoaded).data.occupancy.floors.map((e) => e.floorName));
    } else {
      
      floors.addAll(['G', '1st', '2nd', '3rd']);
    }
    
    final int selectedIndex = state.selectedFloorIndex + 1;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: FloorFilter(
        floors: floors,
        selectedIndex: selectedIndex,
        onSelected: (index) {
          context.read<DashboardCubit>().selectFloor(index - 1);
        },
      ),
    );
  }
}

class _DashboardContentSection extends StatelessWidget {
  final DashboardState state;
  const _DashboardContentSection({required this.state});

  @override
  Widget build(BuildContext context) {
    final currentState = state;
    if (currentState is DashboardLoading) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    if (currentState is DashboardError) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Center(child: Text(currentState.message, style: const TextStyle(color: Colors.red))),
        ),
      );
    }

    if (currentState is! DashboardLoaded) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    final data = currentState.data.occupancy;
    final int selectedFloorIndex = currentState.selectedFloorIndex;
    
    final List<entity.FloorData> displayFloors = selectedFloorIndex == -1 
        ? data.floors 
        : (selectedFloorIndex < data.floors.length ? [data.floors[selectedFloorIndex]] : []);

    if (displayFloors.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: const Center(child: Text('No data found for this floor')),
        ),
      );
    }

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 0),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final floor = displayFloors[index];
            return _StaggeredEntry(
              delayMs: index * 100,
              child: FloorAccordion(
                title: floor.floorName,
                bedInfo: floor.bedInfo,
                isInitialExpanded: index == 0,
                rooms: floor.rooms.map((room) => RoomCard(
                  roomNumber: room.roomNumber,
                  sharingType: room.sharingType,
                  occupancy: room.occupancy,
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
  }
}

class _StaggeredEntry extends StatelessWidget {
  final Widget child;
  final int delayMs;

  const _StaggeredEntry({required this.child, required this.delayMs});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 600 + delayMs),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 30 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
