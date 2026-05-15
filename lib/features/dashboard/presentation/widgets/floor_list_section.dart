import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import '../cubit/dashboard_cubit.dart';
import 'floor_accordion.dart';
import 'room_card.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/occupancy_summary.dart' as entity;

class FloorListSection extends StatelessWidget {
  const FloorListSection({super.key});

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
          return SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 120.h,
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                ),
                childCount: 3,
              ),
            ),
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
                      'no_hostels_added'.tr(),
                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'add_hostel_prompt'.tr(),
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
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text('no_floors_found'.tr())),
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
