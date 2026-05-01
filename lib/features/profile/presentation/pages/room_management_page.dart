import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/occupancy_summary.dart' as entity;
import 'package:stayindia_owner/features/profile/domain/entities/hostel.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/widgets/add_room_sheet.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/room_cubit.dart';
import 'package:stayindia_owner/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:stayindia_owner/core/utils/string_utils.dart';

class RoomManagementPage extends StatelessWidget {
  final Hostel hostel;
  final String floorName;

  const RoomManagementPage({
    super.key,
    required this.hostel,
    required this.floorName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkText, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '$floorName Rooms',
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1.h),
          child: Divider(height: 1, color: Colors.black.withValues(alpha: 0.05)),
        ),
      ),
      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
          }

          if (state is DashboardLoaded) {
            final floor = state.data.occupancy.floors.cast<entity.FloorData>().firstWhere(
              (f) => f.floorName == floorName,
              orElse: () => entity.FloorData(floorName: floorName, bedInfo: '', rooms: []),
            );
            
            final currentRooms = floor.rooms;

            if (currentRooms.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.meeting_room_outlined, size: 48.sp, color: Colors.grey.shade300),
                    SizedBox(height: 16.h),
                    Text(
                      'No rooms on this floor',
                      style: TextStyle(color: AppColors.greyText, fontSize: 14.sp, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.all(16.r),
              itemCount: currentRooms.length,
              itemBuilder: (context, index) {
                final room = currentRooms[index];
                return _RoomManageCard(room: room, hostel: hostel);
              },
            );
          }

          return const Center(child: Text('Something went wrong'));
        },
      ),
      bottomNavigationBar: _buildBottomAction(context),
    );
  }

  Widget _buildBottomAction(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
      ),
      child: BouncingWrapper(
        onTap: () {
          AddRoomSheet.show(
            context,
            initialFloor: int.parse(floorName.replaceAll(RegExp(r'[^0-9]'), '')),
            roomCubit: context.read<RoomCubit>(),
            onSave: (data) async {
              final ownerId = context.read<AuthCubit>().currentOwner?.id ?? '';
              await context.read<RoomCubit>().createRoom(
                    hostelId: hostel.id,
                    ownerId: ownerId,
                    roomTypename: data['roomTypename'],
                    floor: int.parse(floorName.replaceAll(RegExp(r'[^0-9]'), '')),
                    sharingType: data['sharingType'],
                    roomType: data['roomType'],
                    rent: data['rent'],
                    dailyRent: data['dailyRent'],
                    deposit: data['deposit'],
                    maintenance: data['maintenance'],
                  );
              if (context.mounted) {
                context.read<DashboardCubit>().fetchDashboardData(hostel.id);
              }
            },
          );
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
                'Add New Room',
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
}

class _RoomManageCard extends StatelessWidget {
  final entity.Room room;
  final Hostel hostel;

  const _RoomManageCard({required this.room, required this.hostel});

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
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.meeting_room_rounded, color: AppColors.darkText, size: 18.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Room ${room.roomNumber}',
                      style: TextStyle(
                        color: AppColors.darkText,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${StringUtils.formatSharingType(room.sharingType)} • ${room.roomType ?? "N/A"}',
                      style: TextStyle(
                        color: AppColors.greyText,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '₹${room.rent?.toStringAsFixed(0) ?? "0"}',
                style: TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          if (room.features.isNotEmpty) ...[
            Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: room.features.map((f) => _FeatureTag(feature: f)).toList(),
            ),
            SizedBox(height: 12.h),
          ],
          Row(
            children: [
              Expanded(
                child: _SmallActionButton(
                  icon: Icons.edit_outlined,
                  label: 'Edit',
                  onTap: () {},
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _SmallActionButton(
                  icon: Icons.delete_outline_rounded,
                  label: 'Delete',
                  color: Colors.redAccent.withValues(alpha: 0.05),
                  textColor: Colors.redAccent,
                  onTap: () => _showDeleteConfirmation(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Room'),
        content: Text('Are you sure you want to delete Room ${room.roomNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<DashboardCubit>().deleteRoom(room.id, hostel.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _FeatureTag extends StatelessWidget {
  final String feature;
  const _FeatureTag({required this.feature});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        feature,
        style: TextStyle(
          color: AppColors.greyText,
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final Color? textColor;
  final VoidCallback onTap;

  const _SmallActionButton({
    required this.icon,
    required this.label,
    this.color,
    this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BouncingWrapper(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: color ?? const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16.sp, color: textColor ?? AppColors.darkText),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                color: textColor ?? AppColors.darkText,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
