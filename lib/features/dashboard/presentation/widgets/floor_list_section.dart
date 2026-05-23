import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';
import '../cubit/dashboard_cubit.dart';
import 'package:stayindia_owner/core/utils/string_utils.dart';
import 'package:stayindia_owner/features/dashboard/presentation/widgets/floor_accordion.dart';
import 'package:stayindia_owner/features/dashboard/presentation/widgets/room_card.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/occupancy_summary.dart'
    as entity;

class FloorListSection extends StatelessWidget {
  const FloorListSection({super.key});

  @override
  Widget build(BuildContext context) {
    final hostelState = context.watch<HostelCubit>().state;
    if (hostelState is HostelLoaded && hostelState.hostels.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_business_rounded,
                  size: 80.sp,
                  color: AppColors.textSecondary.withValues(alpha: 0.2),
                ),
                SizedBox(height: 24.h),
                Text(
                  'add_property_first'.tr(),
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'start_by_adding_property_desc'.tr(),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

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
          final bool isNoHostels =
              state.message.contains('no_dashboard_data_found') ||
              state.message.contains('not allowed') ||
              state.message.contains('No hostels');

          final bool isForbidden =
              state.message.toLowerCase().contains('forbidden') ||
              state.message.toLowerCase().contains('not allowed');

          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(32.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isForbidden
                          ? Icons.lock_person_rounded
                          : Icons.apartment_rounded,
                      size: 80.sp,
                      color: AppColors.textSecondary.withValues(alpha: 0.2),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      isNoHostels
                          ? 'add_property_first'.tr()
                          : 'Something went wrong',
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      isNoHostels
                          ? 'start_by_adding_property_desc'.tr()
                          : (isForbidden
                                ? 'You don\'t have permission for this property or your session is stale. Please refresh or re-select the property.'
                                : state.message),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (state is! DashboardLoaded) {
          final hostelState = context.watch<HostelCubit>().state;
          if (hostelState is HostelLoaded && hostelState.hostels.isEmpty) {
            return SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_business_rounded,
                        size: 80.sp,
                        color: AppColors.textSecondary.withValues(alpha: 0.2),
                      ),
                      SizedBox(height: 24.h),
                      Text(
                        'add_property_first'.tr(),
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'start_by_adding_property_desc'.tr(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return const SliverToBoxAdapter(child: SizedBox.shrink());
        }

        final data = state.data.occupancy;
        final query = state.searchQuery.toLowerCase();

        final List<entity.FloorData> displayFloors =
            state.selectedFloorIndex == -1
            ? data.floors
            : (state.selectedFloorIndex < data.floors.length
                  ? [data.floors[state.selectedFloorIndex]]
                  : []);

        if (displayFloors.isEmpty) {
          return SliverFillRemaining(
            hasScrollBody: false,
            child: Center(child: Text('no_floors_found'.tr())),
          );
        }



        return SliverPadding(
          padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              final floor = displayFloors[index];
              final filteredRooms = floor.rooms.where((room) {
                if (query.isEmpty) return true;
                final roomNum = room.roomNumber.toLowerCase();
                final hasMatchingTenant = room.beds.any(
                  (bed) =>
                      (bed.tenantName?.toLowerCase().contains(query) ?? false),
                );
                return roomNum.contains(query) || hasMatchingTenant;
              }).toList();
              if (filteredRooms.isEmpty && query.isNotEmpty) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: EdgeInsets.only(bottom: 16.h),
                child: FloorAccordion(
                  title: (() {
                    if (floor.floorName == 'basement' ||
                        (floor.floorNum != null && floor.floorNum! < 0)) {
                      final absNum = floor.floorNum != null
                          ? floor.floorNum!.abs()
                          : 1;
                      if (absNum > 1) {
                        return '${StringUtils.translate('basement', context: context)} $absNum';
                      }
                      return StringUtils.translate(
                        'basement',
                        context: context,
                      );
                    }
                    return StringUtils.translate(
                      floor.floorName == 'ground_floor'
                          ? 'ground_floor'
                          : 'floor_n',
                      context: context,
                      namedArgs: {'n': '${floor.floorNum ?? 0}'},
                    );
                  })(),
                  bedInfo: StringUtils.translate(
                    'beds_free_count',
                    context: context,
                    namedArgs: {
                      'free': '${floor.freeBeds ?? 0}',
                      'total': '${floor.totalBeds ?? 0}',
                    },
                  ),
                  isInitialExpanded: index == 0 || query.isNotEmpty,
                  isGridView: state.isGridView,
                  itemCount: filteredRooms.length,
                  itemBuilder: (context, idx) {
                    final room = filteredRooms[idx];
                    return RoomCard(
                      id: room.id,
                      roomNumber: room.roomNumber,
                      sharingType: room.sharingType,
                      occupancy: room.occupancy,
                      isGridView: state.isGridView,
                      rent: room.rent,
                      dailyRent: room.dailyRent,
                      beds: room.beds
                          .map(
                            (b) => entity.BedInfo(
                              bedNumber: b.bedNumber,
                              status: b.status,
                              tenantName: b.tenantName,
                              tenantAvatar: b.tenantAvatar,
                              tenantId: b.tenantId,
                              isAway: b.isAway,
                            ),
                          )
                          .toList(),
                      roomType: room.roomType,
                      room: room,
                    );
                  },
                ),
              );
            }, childCount: displayFloors.length),
          ),
        );
      },
    );
  }
}
