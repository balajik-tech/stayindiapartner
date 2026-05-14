import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:stayindia_owner/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:stayindia_owner/core/widgets/bouncing_wrapper.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_cubit.dart';
import 'package:stayindia_owner/features/profile/presentation/cubit/hostel_state.dart';

class SummaryCard extends StatelessWidget {
  final String count;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final IconData icon;
  final bool isSelected;
  final bool isBordered;

  const SummaryCard({
    super.key,
    required this.count,
    required this.label,
    required this.color,
    required this.icon,
    this.onTap,
    this.isSelected = false,
    this.isBordered = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool useWhiteStyle = isBordered || color == Colors.white;
    final Color backgroundColor = useWhiteStyle ? Colors.white : color;
    
    final bool isLightBackground = useWhiteStyle || 
                                  ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.light;
    
    final Color contentColor = isLightBackground ? const Color(0xFF0F172A) : Colors.white;

    return BouncingWrapper(
      onTap: onTap,
      scaleFactor: 0.97,
      child: Container(
        width: 140.w,
        height: 72.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        margin: EdgeInsets.only(right: 12.w, bottom: 8.h, top: 4.h),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16.r),
          border: useWhiteStyle ? Border.all(color: const Color(0xFF4285F4), width: 2.0) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: contentColor, size: 22.sp),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    count,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w900,
                      color: contentColor,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      color: contentColor.withValues(alpha: isLightBackground ? 0.7 : 0.9),
                      letterSpacing: -0.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SummaryCardsSection extends StatelessWidget {
  const SummaryCardsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final hostelState = context.watch<HostelCubit>().state;
    final totalProperties = hostelState is HostelLoaded ? hostelState.hostels.length : 0;

    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, state) {
        final bool isLoading = state is DashboardLoading;
        final data = state is DashboardLoaded ? state.data : null;
        final occupancy = data?.occupancy;
        final status = data?.occupancyStatus;
        final ops = data?.dailyOperations;

        return SizedBox(
          height: 94.h,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            children: [
              _buildCard(context, 'properties', '$totalProperties', 'Total Properties', Colors.white, Icons.apartment_rounded, state.selectedMetric, isBordered: true),
              _buildCard(context, 'total', isLoading ? '...' : (occupancy?.totalBeds.toString() ?? '0'), 'Total Beds', const Color(0xFF2C599D), Icons.bed_rounded, state.selectedMetric),
              _buildCard(context, 'overdue', isLoading ? '...' : (ops?.overdueRent.count.toString() ?? '0'), 'Payment Dues', const Color(0xFF800000), Icons.payments_rounded, state.selectedMetric),
              _buildCard(context, 'occupied', isLoading ? '...' : (occupancy?.occupiedBeds.toString() ?? '0'), 'Occupied', const Color(0xFFFF8600), Icons.person_pin_rounded, state.selectedMetric),
              _buildCard(context, 'inside', isLoading ? '...' : (status?.inside.toString() ?? '0'), 'Inside PG', const Color(0xFF34A853), Icons.home_work_rounded, state.selectedMetric),
              _buildCard(context, 'outside', isLoading ? '...' : (status?.outside.toString() ?? '0'), 'Outside PG', const Color(0xFFFFFF00), Icons.exit_to_app_rounded, state.selectedMetric),
              _buildCard(context, 'free', isLoading ? '...' : (occupancy?.freeBeds.toString() ?? '0'), 'Vacant Beds', const Color(0xFF87CEEB), Icons.add_box_rounded, state.selectedMetric),
              _buildCard(context, 'reserved', isLoading ? '...' : (occupancy?.reservedBeds.toString() ?? '0'), 'Pre-booked', const Color(0xFF8E24AA), Icons.event_available_rounded, state.selectedMetric),
              _buildCard(context, 'notice', isLoading ? '...' : (occupancy?.noticeBeds.toString() ?? '0'), 'Move-out Notice', const Color(0xFFFBBC05), Icons.outbox_rounded, state.selectedMetric),
              _buildCard(context, 'away', isLoading ? '...' : (status?.unknown.toString() ?? '0'), 'Away/Vacation', const Color(0xFFE91E63), Icons.luggage_rounded, state.selectedMetric),
              _buildCard(context, 'repair', isLoading ? '...' : '0', 'Minor Repair', const Color(0xFFC5C6C7), Icons.handyman_rounded, state.selectedMetric),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCard(BuildContext context, String id, String count, String label, Color color, IconData icon, String? selectedMetric, {bool isBordered = false}) {
    return SummaryCard(
      count: count,
      label: label,
      color: color,
      icon: icon,
      isBordered: isBordered,
      isSelected: selectedMetric == id,
      onTap: () => context.read<DashboardCubit>().toggleMetric(id),
    );
  }
}
