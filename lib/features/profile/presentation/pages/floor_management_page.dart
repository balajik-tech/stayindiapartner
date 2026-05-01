import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/core/theme/app_colors.dart';
import 'package:stayindia_owner/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:stayindia_owner/features/profile/domain/entities/hostel.dart';
import 'package:stayindia_owner/features/dashboard/domain/entities/occupancy_summary.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/profile/presentation/widgets/add_floor_sheet.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/room_cubit.dart';
import 'package:stayindia_owner/injection_container.dart';
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
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.darkText, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Floor Management',
          style: TextStyle(
            color: AppColors.darkText,
            fontSize: 15.sp, // Reduced from 18
            fontWeight: FontWeight.w700, // Reduced from 900
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
            final floors = state.data.occupancy.floors;
            return ListView.builder(
              padding: EdgeInsets.all(16.r), // Reduced from 20
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
                Icon(Icons.error_outline_rounded, size: 40.sp, color: Colors.grey),
                SizedBox(height: 12.h),
                Text('Failed to load floors', style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
                TextButton(
                  onPressed: () => context.read<DashboardCubit>().fetchDashboardData(hostel.id),
                  child: const Text('Retry'),
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
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black.withValues(alpha: 0.05))),
      ),
      child: BouncingWrapper(
        onTap: () {
          _showAddFloorDialog(context);
        },
        child: Container(
          height: 48.h, // Reduced from 54
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(10.r), // Reduced from 16
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_rounded, color: Colors.white, size: 18.sp),
              SizedBox(width: 6.w),
              Text(
                'Add New Floor',
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

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h), // Reduced from 16
      padding: EdgeInsets.all(14.r), // Reduced from 20
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r), // Reduced from 24
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.r), // Reduced from 10
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.layers_rounded, color: AppColors.primaryBlue, size: 18.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      floor.floorName,
                      style: TextStyle(
                        color: AppColors.darkText,
                        fontSize: 14.sp, // Reduced from 16
                        fontWeight: FontWeight.w700, // Reduced from 800
                      ),
                    ),
                    Text(
                      '${floor.rooms.length} Rooms • ${floor.bedInfo}',
                      style: TextStyle(
                        color: AppColors.greyText,
                        fontSize: 11.sp, // Reduced from 12
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: AppColors.greyText, size: 18),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Custom floor labels coming soon!')),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 18),
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
                    ),
                  ),
                ),
              );
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Manage Rooms',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 4.w),
                Icon(Icons.arrow_forward_rounded, color: AppColors.primaryBlue, size: 14.sp),
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
        title: const Text('Delete Floor'),
        content: Text('Are you sure you want to delete ${floor.floorName} and all its ${floor.rooms.length} rooms? This action is permanent.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              final roomIds = floor.rooms.map((r) => r.id).toList();
              context.read<DashboardCubit>().deleteRoomsBulk(roomIds, hostel.id);
            },
            child: const Text('Delete All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
