import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:stayindia_owner/features/profile/domain/entities/hostel.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/occupancy_summary.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/profile/presentation/widgets/add_floor_sheet.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/room_cubit.dart';
import 'package:stayindia_owner/injection_container.dart';
import 'package:stayindia_owner/core/utils/string_utils.dart';
import 'room_management_page.dart';

class FloorManagementPage extends StatelessWidget {
  final Hostel hostel;

  const FloorManagementPage({super.key, required this.hostel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.darkText,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'floor_management'.tr(),
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Divider(
            height: 1,
            color: Colors.black.withValues(alpha: 0.05),
          ),
        ),
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue),
            );
          }

          if (state is DashboardLoaded) {
            final floors = state.data.occupancy.floors;
            return ListView.builder(
              padding: EdgeInsets.all(16.r),
              itemCount: floors.length,
              itemBuilder: (context, index) {
                final floor = floors[index];
                return _FloorCard(floor: floor, hostel: hostel);
              },
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline_rounded,
                  size: 40.sp,
                  color: Colors.grey,
                ),
                SizedBox(height: 12.h),
                Text(
                  'failed_load_floors'.tr(),
                  style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                ),
                TextButton(
                  onPressed: () => context
                      .read<DashboardCubit>()
                      .fetchDashboardData(hostel.id),
                  child: Text('btn_retry'.tr()),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: _buildBottomAction(context),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20.w,
        12.h,
        20.w,
        MediaQuery.of(context).padding.bottom > 0
            ? MediaQuery.of(context).padding.bottom + 8.h
            : 24.h,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
        ),
      ),
      child: BouncingWrapper(
        onTap: () {
          _showAddFloorDialog(context);
        },
        child: Container(
          height: 48.h,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, color: Colors.white, size: 18.sp),
              SizedBox(width: 6.w),
              Text(
                'add_new_floor'.tr(),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddFloorDialog(BuildContext context) {
    AddFloorSheet.show(
      context,
      hostelId: hostel.id,
      roomCubit: sl<RoomCubit>(),
      dashboardCubit: context.read<DashboardCubit>(),
    );
  }
}

class _FloorCard extends StatelessWidget {
  final FloorData floor;
  final Hostel hostel;

  const _FloorCard({required this.floor, required this.hostel});

  String _getFloorDisplayName(BuildContext context) {
    if (floor.floorName == 'basement' ||
        (floor.floorNum != null && floor.floorNum! < 0)) {
      final absNum = floor.floorNum != null ? floor.floorNum!.abs() : 1;
      if (absNum > 1) {
        return '${StringUtils.translate('basement', context: context)} $absNum';
      }
      return StringUtils.translate('basement', context: context);
    }
    return StringUtils.translate(
      floor.floorName == 'ground_floor' ? 'ground_floor' : 'floor_n',
      context: context,
      namedArgs: {'n': '${floor.floorNum ?? 0}'},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.layers_rounded,
                  color: AppColors.primaryBlue,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getFloorDisplayName(context),
                      style: TextStyle(
                        color: AppColors.darkText,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${_getFloorDisplayName(context)} • ${'rooms_count'.tr(namedArgs: {'count': floor.rooms.length.toString()})} • ${StringUtils.translate('beds_free_count', context: context, namedArgs: {'free': '${floor.freeBeds ?? 0}', 'total': '${floor.totalBeds ?? 0}'})}',
                      style: TextStyle(
                        color: AppColors.greyText,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.redAccent,
                  size: 18,
                ),
                onPressed: () => _showDeleteFloorConfirmation(context),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          const Divider(color: Color(0xFFF8FAFC)),
          SizedBox(height: 4.h),
          BouncingWrapper(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider<RoomCubit>(
                    create: (context) => sl<RoomCubit>(),
                    child: RoomManagementPage(
                      hostel: hostel,
                      floorName: floor.floorName,
                      floorNum: floor.floorNum,
                    ),
                  ),
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'manage_rooms'.tr(),
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.primaryBlue,
                  size: 14.sp,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteFloorConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('delete_floor'.tr()),
        content: Text(
          'delete_floor_confirm'.tr(
            namedArgs: {
              'floor': floor.floorName,
              'count': floor.rooms.length.toString(),
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('btn_cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              final roomIds = floor.rooms.map((r) => r.id).toList();
              context.read<DashboardCubit>().deleteRoomsBulk(
                roomIds,
                hostel.id,
              );
            },
            child: Text(
              'delete_all'.tr(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
